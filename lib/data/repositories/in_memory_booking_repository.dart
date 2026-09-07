import 'dart:async';

// ignore_for_file: prefer_initializing_formals

import 'package:salon_book/core/notifications/appointment_notifier.dart';
import 'package:salon_book/core/utils/date_time_utils.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/domain/repositories/booking_repository.dart';
import 'package:salon_book/domain/repositories/salon_repository.dart';
import 'package:salon_book/features/booking/domain/availability_engine.dart';
import 'package:salon_book/features/booking/domain/booking_conflict_exception.dart';

class InMemoryBookingRepository implements BookingRepository {
  InMemoryBookingRepository({
    AvailabilityEngine engine = const AvailabilityEngine(),
    AppointmentNotifier? notifier,
    SalonRepository? salonRepository,
    DateTime Function()? clock,
  }) : _engine = engine,
       _notifier = notifier ?? NoOpAppointmentNotifier(),
       _salonRepository = salonRepository,
       _clock = clock ?? DateTime.now;

  final AvailabilityEngine _engine;
  final AppointmentNotifier _notifier;
  final SalonRepository? _salonRepository;
  final DateTime Function() _clock;
  final List<Booking> _bookings = [];
  final _controller = StreamController<List<Booking>>.broadcast();

  List<Booking> get all => List.unmodifiable(_bookings);

  @override
  Future<List<Booking>> getBookings({String? clientId, String? stylistId}) async {
    await syncStatuses();
    return _bookings
        .where((booking) {
          if (clientId != null && booking.clientId != clientId) return false;
          if (stylistId != null && booking.stylistId != stylistId) return false;
          return true;
        })
        .toList(growable: false);
  }

  @override
  Future<Booking?> getBookingById(String id) async {
    await syncStatuses();
    try {
      return _bookings.firstWhere((booking) => booking.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Stream<List<Booking>> watchByClient(String clientId) async* {
    yield await getBookings(clientId: clientId);
    yield* _controller.stream.map(
      (bookings) => bookings.where((booking) => booking.clientId == clientId).toList(growable: false),
    );
  }

  @override
  Future<void> syncStatuses({DateTime? now}) async {
    final current = now ?? _clock();
    var changed = false;
    for (var i = 0; i < _bookings.length; i++) {
      final booking = _bookings[i];
      if (booking.status == BookingStatus.upcoming && !booking.end.isAfter(current)) {
        _bookings[i] = booking.copyWith(status: BookingStatus.completed);
        changed = true;
      }
    }
    if (changed) _emit();
  }

  @override
  Future<Booking> createBooking({
    required String salonId,
    required String serviceId,
    required String clientId,
    required DateTime start,
    required int durationMinutes,
    required List<Stylist> stylists,
    String? preferredStylistId,
  }) async {
    final candidates = preferredStylistId == null
        ? stylists
        : stylists.where((stylist) => stylist.id == preferredStylistId).toList(growable: false);

    final stylist = _engine.firstFreeStylist(
      stylists: candidates,
      start: start,
      durationMinutes: durationMinutes,
      bookings: _bookings,
    );
    if (stylist == null) {
      throw const BookingConflictException();
    }

    final booking = Booking(
      id: 'booking-${stylist.id}-${start.microsecondsSinceEpoch}',
      salonId: salonId,
      serviceId: serviceId,
      stylistId: stylist.id,
      clientId: clientId,
      start: start,
      end: DateTimeUtils.addMinutes(start, durationMinutes),
      status: BookingStatus.upcoming,
    );
    _bookings.add(booking);
    _emit();
    await _scheduleNotifications(booking);
    return booking;
  }

  @override
  Future<Booking> cancelBooking(String bookingId) async {
    final index = _indexOf(bookingId);
    final booking = _bookings[index];
    if (booking.status != BookingStatus.upcoming) {
      throw StateError('Only upcoming appointments can be cancelled.');
    }
    final updated = booking.copyWith(status: BookingStatus.cancelled);
    _bookings[index] = updated;
    _emit();
    await _notifier.cancelForBooking(bookingId);
    return updated;
  }

  @override
  Future<Booking> rescheduleBooking({
    required String bookingId,
    required DateTime newStart,
    required int durationMinutes,
    required List<Stylist> stylists,
  }) async {
    final index = _indexOf(bookingId);
    final existing = _bookings[index];
    if (existing.status != BookingStatus.upcoming) {
      throw StateError('Only upcoming appointments can be rescheduled.');
    }

    final others = _bookings.where((booking) => booking.id != bookingId).toList(growable: false);
    final stylist = _engine.firstFreeStylist(
      stylists: stylists.where((stylist) => stylist.id == existing.stylistId).toList(growable: false),
      start: newStart,
      durationMinutes: durationMinutes,
      bookings: others,
    );
    if (stylist == null) {
      throw const BookingConflictException();
    }

    await _notifier.cancelForBooking(bookingId);
    final updated = existing.copyWith(
      start: newStart,
      end: DateTimeUtils.addMinutes(newStart, durationMinutes),
      stylistId: stylist.id,
    );
    _bookings[index] = updated;
    _emit();
    await _scheduleNotifications(updated);
    return updated;
  }

  int _indexOf(String bookingId) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) throw StateError('Booking not found.');
    return index;
  }

  void _emit() => _controller.add(List.unmodifiable(_bookings));

  Future<void> _scheduleNotifications(Booking booking) async {
    final salonRepo = _salonRepository;
    if (salonRepo == null) return;
    final salon = await salonRepo.getSalonById(booking.salonId);
    if (salon == null) return;
    SalonService? service;
    for (final item in salon.services) {
      if (item.id == booking.serviceId) service = item;
    }
    if (service == null) return;
    await _notifier.scheduleForBooking(
      booking: booking,
      salonName: salon.name,
      serviceName: service.name,
    );
  }
}
