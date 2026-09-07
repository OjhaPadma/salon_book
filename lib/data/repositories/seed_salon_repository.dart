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
