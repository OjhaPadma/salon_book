import 'package:equatable/equatable.dart';

import 'review.dart';
import 'service.dart';
import 'stylist.dart';

class Salon extends Equatable {
  const Salon({
    required this.id,
    required this.name,
    required this.tagline,
    required this.address,
    required this.city,
    required this.rating,
    required this.reviewCount,
    required this.coverUrl,
    required this.galleryUrls,
    required this.services,
    required this.stylists,
    required this.reviews,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String tagline;
  final String address;
  final String city;
  final double rating;
  final int reviewCount;
  final String coverUrl;
  final List<String> galleryUrls;
  final List<SalonService> services;
  final List<Stylist> stylists;
  final List<Review> reviews;
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [
    id,
    name,
    tagline,
    address,
    city,
    rating,
    reviewCount,
    coverUrl,
    galleryUrls,
    services,
    stylists,
    reviews,
    latitude,
    longitude,
  ];
}
