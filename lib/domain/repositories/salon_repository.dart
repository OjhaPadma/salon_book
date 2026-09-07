import 'package:salon_book/domain/models/models.dart';

abstract class SalonRepository {
  Future<List<Salon>> getSalons();

  Future<Salon?> getSalonById(String id);
}
