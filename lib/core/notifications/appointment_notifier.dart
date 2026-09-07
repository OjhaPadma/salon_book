import 'package:salon_book/domain/models/booking.dart';

abstract class AppointmentNotifier {
  Future<void> scheduleForBooking({
    required Booking booking,
    required String salonName,
    required String serviceName,
  });

  Future<void> cancelForBooking(String bookingId);
}

class NoOpAppointmentNotifier implements AppointmentNotifier {
  @override
  Future<void> scheduleForBooking({
    required Booking booking,
    required String salonName,
    required String serviceName,
  }) async {}

  @override
  Future<void> cancelForBooking(String bookingId) async {}
}
