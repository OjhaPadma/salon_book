import 'package:flutter_test/flutter_test.dart';
import 'package:salon_book/data/seed/seed_salons.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/features/booking/domain/availability_engine.dart';

void main() {
  const engine = AvailabilityEngine();
  final meera = seedSalons.first.stylists.first;
  final arun = seedSalons.first.stylists[1];
  final monday = DateTime(2026, 9, 7, 8);
  final day = DateTime(2026, 9, 7);

  Booking booking({
    required DateTime start,
    required DateTime end,
    String stylistId = 'stylist-meera',
    BookingStatus status = BookingStatus.upcoming,
  }) {
    return Booking(
      id: 'b-${start.millisecondsSinceEpoch}',
      salonId: 'salon-noor',
      serviceId: 'noor-cut',
      stylistId: stylistId,
      clientId: 'guest-client',
      start: start,
      end: end,
      status: status,
    );
  }

  test('skips closed days and times already started', () {
    final sunday = engine.slotsForStylist(
      stylist: meera,
      durationMinutes: 60,
      day: DateTime(2026, 9, 6),
      bookings: const [],
      now: monday,
    );
    expect(sunday, isEmpty);

    final slots = engine.slotsForStylist(
      stylist: meera,
      durationMinutes: 60,
      day: day,
      bookings: const [],
      now: DateTime(2026, 9, 7, 10, 7),
    );
    expect(slots.first.start, DateTime(2026, 9, 7, 10, 15));
  });

  test('buffer blocks the next start until cleanup ends', () {
    final existing = booking(
      start: DateTime(2026, 9, 7, 10),
      end: DateTime(2026, 9, 7, 11),
    );
    final slots = engine.slotsForStylist(
      stylist: meera,
      durationMinutes: 60,
      day: day,
      bookings: [existing],
      now: monday,
    );
    final starts = slots.map((slot) => slot.start).toSet();

    expect(starts.contains(DateTime(2026, 9, 7, 10)), isFalse);
    expect(starts.contains(DateTime(2026, 9, 7, 10, 45)), isFalse);
    expect(starts.contains(DateTime(2026, 9, 7, 11)), isFalse);
    expect(starts.contains(DateTime(2026, 9, 7, 11, 15)), isTrue);
    expect(starts.contains(DateTime(2026, 9, 7, 9)), isTrue);
  });

  test('back-to-back is allowed once the buffer has elapsed', () {
    final conflict = engine.isConflict(
      start: DateTime(2026, 9, 7, 11),
      end: DateTime(2026, 9, 7, 12),
      bookings: [
        booking(start: DateTime(2026, 9, 7, 10), end: DateTime(2026, 9, 7, 11)),
      ],
      bufferMinutes: 15,
    );
    final allowed = engine.isConflict(
      start: DateTime(2026, 9, 7, 11, 15),
      end: DateTime(2026, 9, 7, 12, 15),
      bookings: [
        booking(start: DateTime(2026, 9, 7, 10), end: DateTime(2026, 9, 7, 11)),
      ],
      bufferMinutes: 15,
    );
    expect(conflict, isTrue);
    expect(allowed, isFalse);
  });

  test('any-available keeps a start if another stylist is free', () {
    final existing = booking(
      start: DateTime(2026, 9, 7, 10),
      end: DateTime(2026, 9, 7, 11),
    );
    final slots = engine.slotsForAnyStylist(
      stylists: [meera, arun],
      durationMinutes: 60,
      day: day,
      bookings: [existing],
      now: monday,
    );
    final ten = slots.firstWhere((slot) => slot.start == DateTime(2026, 9, 7, 10));
    expect(ten.stylistId, arun.id);
  });

  test('cancelled bookings do not occupy a chair', () {
    final cancelled = booking(
      start: DateTime(2026, 9, 7, 10),
      end: DateTime(2026, 9, 7, 11),
      status: BookingStatus.cancelled,
    );
    expect(
      engine.isConflict(
        start: DateTime(2026, 9, 7, 10),
        end: DateTime(2026, 9, 7, 11),
        bookings: [cancelled],
        bufferMinutes: 15,
      ),
      isFalse,
    );
  });
}
