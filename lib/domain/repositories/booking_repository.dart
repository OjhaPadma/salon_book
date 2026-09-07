import 'package:salon_book/domain/models/models.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookings({String? clientId, String? stylistId});

  Future<Booking?> getBookingById(String id);

  Stream<List<Booking>> watchByClient(String clientId);

  Future<void> syncStatuses({DateTime? now});

  Future<Booking> createBooking({
    required String salonId,
    required String serviceId,
    required String clientId,
    required DateTime start,
    required int durationMinutes,
    required List<Stylist> stylists,
    String? preferredStylistId,
  });

  Future<Booking> cancelBooking(String bookingId);

  Future<Booking> rescheduleBooking({
    required String bookingId,
    required DateTime newStart,
    required int durationMinutes,
    required List<Stylist> stylists,
  });
}
