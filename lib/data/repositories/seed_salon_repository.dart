import 'package:salon_book/data/seed/seed_salons.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/domain/repositories/salon_repository.dart';

class SeedSalonRepository implements SalonRepository {
  final Map<String, List<Review>> _extraReviews = {};
  final Set<String> _reviewedBookingIds = {};

  @override
  Future<List<Salon>> getSalons() async {
    return seedSalons.map(_withExtraReviews).toList(growable: false);
  }

  @override
  Future<Salon?> getSalonById(String id) async {
    try {
      return _withExtraReviews(seedSalons.firstWhere((salon) => salon.id == id));
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> submitReview({
    required String salonId,
    required String bookingId,
    required String author,
    required double rating,
    required String comment,
  }) async {
    final review = Review(
      id: 'review-$bookingId',
      salonId: salonId,
      author: author,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    _extraReviews.putIfAbsent(salonId, () => []).add(review);
    _reviewedBookingIds.add(bookingId);
  }

  @override
  Future<bool> hasReviewForBooking(String bookingId) async => _reviewedBookingIds.contains(bookingId);

  Salon _withExtraReviews(Salon salon) {
    final extra = _extraReviews[salon.id] ?? const <Review>[];
    if (extra.isEmpty) return salon;
    return Salon(
      id: salon.id,
      name: salon.name,
      tagline: salon.tagline,
      address: salon.address,
      city: salon.city,
      rating: salon.rating,
      reviewCount: salon.reviewCount + extra.length,
      coverUrl: salon.coverUrl,
      galleryUrls: salon.galleryUrls,
      services: salon.services,
      stylists: salon.stylists,
      reviews: [...extra, ...salon.reviews],
      latitude: salon.latitude,
      longitude: salon.longitude,
    );
  }
}
