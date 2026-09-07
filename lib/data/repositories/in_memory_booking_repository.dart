import 'dart:async';

import 'package:salon_book/core/utils/date_time_utils.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/domain/repositories/booking_repository.dart';
import 'package:salon_book/features/booking/domain/availability_engine.dart';
import 'package:salon_book/features/booking/domain/booking_conflict_exception.dart';

class InMemoryBookingRepository implements BookingRepository {
  // ignore: prefer_initializing_formals
  InMemoryBookingRepository({AvailabilityEngine engine = const AvailabilityEngine()}) : _engine = engine;

  final AvailabilityEngine _engine;
  final List<Booking> _bookings = [];
  final _controller = StreamController<List<Booking>>.broadcast();

  List<Booking> get all => List.unmodifiable(_bookings);

  @override
  Future<List<Booking>> getBookings({String? clientId, String? stylistId}) async {
    return _bookings
        .where((booking) {
          if (clientId != null && booking.clientId != clientId) return false;
          if (stylistId != null && booking.stylistId != stylistId) return false;
          return true;
        })
        .toList(growable: false);
  }

  @override
  Stream<List<Booking>> watchByClient(String clientId) async* {
    yield await getBookings(clientId: clientId);
    yield* _controller.stream.map(
      (bookings) => bookings.where((booking) => booking.clientId == clientId).toList(growable: false),
    );
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
    _controller.add(List.unmodifiable(_bookings));
    return booking;
  }
}
