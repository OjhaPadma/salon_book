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

  test('cancel marks booking as cancelled', () async {
    final created = await book(stylistId: 'stylist-meera');
    final cancelled = await repository.cancelBooking(created.id);
    expect(cancelled.status, BookingStatus.cancelled);
    expect(book(stylistId: 'stylist-meera'), completes);
  });

  test('reschedule moves a booking to a new slot', () async {
    final created = await book(stylistId: 'stylist-meera');
    final moved = await repository.rescheduleBooking(
      bookingId: created.id,
      newStart: DateTime(2026, 9, 7, 14),
      durationMinutes: 60,
      stylists: stylists,
    );
    expect(moved.start, DateTime(2026, 9, 7, 14));
    expect(moved.status, BookingStatus.upcoming);
  });

  test('syncStatuses completes past upcoming bookings', () async {
    repository = InMemoryBookingRepository(
      clock: () => DateTime(2026, 9, 7, 12),
    );
    await repository.createBooking(
      salonId: 'salon-noor',
      serviceId: 'noor-cut',
      clientId: 'guest-client',
      start: DateTime(2026, 9, 7, 9),
      durationMinutes: 60,
      stylists: stylists,
      preferredStylistId: 'stylist-meera',
    );
    await repository.syncStatuses(now: DateTime(2026, 9, 7, 12));
    final bookings = await repository.getBookings();
    expect(bookings.single.status, BookingStatus.completed);
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

  test('mark completed and no-show update status', () async {
    final created = await book(stylistId: 'stylist-meera');
    final completed = await repository.markCompleted(created.id);
    expect(completed.status, BookingStatus.completed);

    final second = await book(
      at: DateTime(2026, 9, 7, 14),
      stylistId: 'stylist-meera',
    );
    final noShow = await repository.markNoShow(second.id);
    expect(noShow.status, BookingStatus.noShow);
  });

  test('watchBySalon emits salon bookings', () async {
    await book(stylistId: 'stylist-meera');
    final seen = await repository.watchBySalon('salon-noor').first;
    expect(seen, isNotEmpty);
    expect(seen.every((booking) => booking.salonId == 'salon-noor'), isTrue);
  });
}
