import 'package:flutter_test/flutter_test.dart';
import 'package:salon_book/data/seed/seed_salons.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/features/staff/domain/staff_schedule_builder.dart';

void main() {
  final salon = seedSalons.first;
  final day = DateTime(2026, 9, 7);

  test('builds entries grouped by stylist for a day', () {
    final bookings = [
      Booking(
        id: 'b1',
        salonId: salon.id,
        serviceId: 'noor-cut',
        stylistId: 'stylist-meera',
        clientId: 'client-1',
        start: DateTime(2026, 9, 7, 10),
        end: DateTime(2026, 9, 7, 11),
        status: BookingStatus.upcoming,
      ),
      Booking(
        id: 'b2',
        salonId: salon.id,
        serviceId: 'noor-blow',
        stylistId: 'stylist-arun',
        clientId: 'guest-client',
        start: DateTime(2026, 9, 7, 14),
        end: DateTime(2026, 9, 7, 14, 45),
        status: BookingStatus.upcoming,
      ),
    ];

    final entries = StaffScheduleBuilder.build(salon: salon, bookings: bookings, day: day);
    expect(entries, hasLength(2));
    expect(entries.first.clientName, 'Priya Kapoor');
    expect(entries.last.clientName, 'Guest');
  });

  test('skips cancelled bookings', () {
    final bookings = [
      Booking(
        id: 'b1',
        salonId: salon.id,
        serviceId: 'noor-cut',
        stylistId: 'stylist-meera',
        clientId: 'client-1',
        start: DateTime(2026, 9, 7, 10),
        end: DateTime(2026, 9, 7, 11),
        status: BookingStatus.cancelled,
      ),
    ];
    expect(StaffScheduleBuilder.build(salon: salon, bookings: bookings, day: day), isEmpty);
  });
}
