import 'package:salon_book/core/utils/date_time_utils.dart';
import 'package:salon_book/domain/models/models.dart';

class AvailabilityEngine {
  const AvailabilityEngine({this.stepMinutes = 15});

  final int stepMinutes;

  List<TimeSlot> slotsForStylist({
    required Stylist stylist,
    required int durationMinutes,
    required DateTime day,
    required List<Booking> bookings,
    DateTime? now,
  }) {
    final window = stylist.workingHours.forWeekday(day.weekday);
    if (window == null) return const [];

    final dayStart = DateTimeUtils.startOfDay(day);
    var cursor = DateTimeUtils.addMinutes(dayStart, window.startMinutes);
    final workEnd = DateTimeUtils.addMinutes(dayStart, window.endMinutes);
    final latestStart = workEnd.subtract(Duration(minutes: durationMinutes));

    final blocking = bookings
        .where(
          (booking) =>
              booking.stylistId == stylist.id &&
              booking.status == BookingStatus.upcoming &&
              DateTimeUtils.startOfDay(booking.start) == dayStart,
        )
        .toList(growable: false);

    final slots = <TimeSlot>[];
    while (!cursor.isAfter(latestStart)) {
      final end = DateTimeUtils.addMinutes(cursor, durationMinutes);
      final inPast = now != null && !cursor.isAfter(now);
      final taken = isConflict(
        start: cursor,
        end: end,
        bookings: blocking,
        bufferMinutes: stylist.bufferMinutes,
      );
      if (!inPast && !taken) {
        slots.add(
          TimeSlot(
            id: '${stylist.id}-${cursor.toIso8601String()}',
            stylistId: stylist.id,
            start: cursor,
            end: end,
          ),
        );
      }
      cursor = DateTimeUtils.addMinutes(cursor, stepMinutes);
    }
    return slots;
  }

  /// One slot per start time; the first stylist who is free is assigned.
  List<TimeSlot> slotsForAnyStylist({
    required List<Stylist> stylists,
    required int durationMinutes,
    required DateTime day,
    required List<Booking> bookings,
    DateTime? now,
  }) {
    final byStart = <DateTime, TimeSlot>{};
    for (final stylist in stylists) {
      for (final slot in slotsForStylist(
        stylist: stylist,
        durationMinutes: durationMinutes,
        day: day,
        bookings: bookings,
        now: now,
      )) {
        byStart.putIfAbsent(slot.start, () => slot);
      }
    }
    final slots = byStart.values.toList()..sort((a, b) => a.start.compareTo(b.start));
    return slots;
  }

  bool isConflict({
    required DateTime start,
    required DateTime end,
    required List<Booking> bookings,
    required int bufferMinutes,
  }) {
    for (final booking in bookings) {
      if (booking.status != BookingStatus.upcoming) continue;
      if (booking.stylistId.isEmpty) continue;
      final occupiedEnd = DateTimeUtils.withBuffer(booking.end, bufferMinutes: bufferMinutes);
      if (DateTimeUtils.overlaps(
        startA: start,
        endA: end,
        startB: booking.start,
        endB: occupiedEnd,
      )) {
        return true;
      }
    }
    return false;
  }

  DateTime firstOpenDay(List<Stylist> stylists, {DateTime? from}) {
    final start = DateTimeUtils.startOfDay(from ?? DateTime.now());
    for (var offset = 0; offset < 14; offset++) {
      final day = start.add(Duration(days: offset));
      if (stylists.any((stylist) => stylist.workingHours.forWeekday(day.weekday) != null)) {
        return day;
      }
    }
    return start;
  }

  Stylist? firstFreeStylist({
    required List<Stylist> stylists,
    required DateTime start,
    required int durationMinutes,
    required List<Booking> bookings,
  }) {
    final end = DateTimeUtils.addMinutes(start, durationMinutes);
    for (final stylist in stylists) {
      final window = stylist.workingHours.forWeekday(start.weekday);
      if (window == null) continue;
      final dayStart = DateTimeUtils.startOfDay(start);
      final workStart = DateTimeUtils.addMinutes(dayStart, window.startMinutes);
      final workEnd = DateTimeUtils.addMinutes(dayStart, window.endMinutes);
      if (start.isBefore(workStart) || end.isAfter(workEnd)) continue;
      final blocking = bookings.where((booking) => booking.stylistId == stylist.id).toList();
      if (!isConflict(
        start: start,
        end: end,
        bookings: blocking,
        bufferMinutes: stylist.bufferMinutes,
      )) {
        return stylist;
      }
    }
    return null;
  }
}
