import 'package:salon_book/data/seed/seed_salons.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/domain/repositories/salon_repository.dart';

class SeedSalonRepository implements SalonRepository {
  @override
  Future<List<Salon>> getSalons() async => List.unmodifiable(seedSalons);

  @override
  Future<Salon?> getSalonById(String id) async {
    try {
      return seedSalons.firstWhere((salon) => salon.id == id);
    } on StateError {
      return null;
    }
  }
}

class InMemoryBookingRepository implements BookingRepository {
  final List<Booking> _bookings = [];

  @override
  Future<List<Booking>> getBookings({required String clientId}) async {
    return _bookings.where((booking) => booking.clientId == clientId).toList(growable: false);
  }
}
