import 'package:flutter_test/flutter_test.dart';
import 'package:salon_book/data/repositories/in_memory_booking_repository.dart';
import 'package:salon_book/data/seed/seed_salons.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/features/booking/domain/availability_engine.dart';
import 'package:salon_book/features/booking/domain/booking_conflict_exception.dart';

void main() {
  late InMemoryBookingRepository repository;
  final stylists = seedSalons.first.stylists;
  final start = DateTime(2026, 9, 7, 10);

  setUp(() {
    repository = InMemoryBookingRepository();
  });

  Future<Booking> book({DateTime? at, String? stylistId}) {
    return repository.createBooking(
      salonId: 'salon-noor',
      serviceId: 'noor-cut',
      clientId: 'guest-client',
      start: at ?? start,
      durationMinutes: 60,
      stylists: stylists,
      preferredStylistId: stylistId,
    );
  }

  test('persists a booking and hides the slot for that stylist', () async {
    final created = await book(stylistId: 'stylist-meera');
    expect(created.stylistId, 'stylist-meera');
    expect(created.end, DateTime(2026, 9, 7, 11));

    expect(book(stylistId: 'stylist-meera'), throwsA(isA<BookingConflictException>()));
  });

  test('any-available falls through to the next free stylist', () async {
    await book(stylistId: 'stylist-meera');
    final second = await book();
    expect(second.stylistId, 'stylist-arun');
  });

  test('booked slot disappears from availability for that stylist', () async {
    await book(stylistId: 'stylist-meera');
    const engine = AvailabilityEngine();
    final slots = engine.slotsForStylist(
      stylist: stylists.first,
      durationMinutes: 60,
      day: DateTime(2026, 9, 7),
      bookings: repository.all,
      now: DateTime(2026, 9, 7, 8),
    );
    expect(slots.any((slot) => slot.start == start), isFalse);
  });

  test('watchByClient includes newly created bookings', () async {
    await book();
    final seen = await repository.watchByClient('guest-client').first;
    expect(seen, hasLength(1));
  });
}
