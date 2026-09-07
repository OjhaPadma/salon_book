import 'package:salon_book/domain/models/models.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookings({String? clientId, String? stylistId});

  Stream<List<Booking>> watchByClient(String clientId);

  Future<Booking> createBooking({
    required String salonId,
    required String serviceId,
    required String clientId,
    required DateTime start,
    required int durationMinutes,
    required List<Stylist> stylists,
    String? preferredStylistId,
  });
}
