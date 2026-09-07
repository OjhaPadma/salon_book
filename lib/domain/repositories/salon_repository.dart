import 'package:salon_book/domain/models/models.dart';

abstract class SalonRepository {
  Future<List<Salon>> getSalons();

  Future<Salon?> getSalonById(String id);

  Future<void> submitReview({
    required String salonId,
    required String bookingId,
    required String author,
    required double rating,
    required String comment,
  });

  Future<bool> hasReviewForBooking(String bookingId);
}
