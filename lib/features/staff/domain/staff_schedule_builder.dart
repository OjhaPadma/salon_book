import 'package:salon_book/core/constants/guest_ids.dart';
import 'package:salon_book/data/repositories/seed_auth_repository.dart';
import 'package:salon_book/domain/models/models.dart';

class StaffScheduleEntry {
  const StaffScheduleEntry({
    required this.booking,
    required this.stylist,
    this.service,
    required this.clientName,
  });

  final Booking booking;
  final Stylist stylist;
  final SalonService? service;
  final String clientName;
}

abstract final class StaffScheduleBuilder {
  static List<StaffScheduleEntry> build({
    required Salon salon,
    required List<Booking> bookings,
    required DateTime day,
  }) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final entries = <StaffScheduleEntry>[];

    for (final booking in bookings) {
      if (DateTime(booking.start.year, booking.start.month, booking.start.day) != dayStart) continue;
      if (booking.status == BookingStatus.cancelled) continue;

      Stylist? stylist;
      SalonService? service;
      for (final item in salon.stylists) {
        if (item.id == booking.stylistId) stylist = item;
      }
      for (final item in salon.services) {
        if (item.id == booking.serviceId) service = item;
      }
      if (stylist == null) continue;

      entries.add(
        StaffScheduleEntry(
          booking: booking,
          stylist: stylist,
          service: service,
          clientName: _clientName(booking.clientId),
        ),
      );
    }

    entries.sort((a, b) => a.booking.start.compareTo(b.booking.start));
    return entries;
  }

  static String _clientName(String clientId) {
    if (clientId == SeedAuthRepository.client.id) return SeedAuthRepository.client.name;
    if (clientId == GuestIds.client) return 'Guest';
    return 'Client';
  }
}
