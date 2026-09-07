import 'package:salon_book/domain/models/salon.dart';

List<Salon> filterSalons({
  required List<Salon> salons,
  String query = '',
  String? category,
  double? minRating,
}) {
  final needle = query.trim().toLowerCase();

  return salons.where((salon) {
    if (minRating != null && salon.rating < minRating) return false;
    if (category != null && !salon.services.any((service) => service.category == category)) {
      return false;
    }
    if (needle.isEmpty) return true;
    return _matchesQuery(salon, needle);
  }).toList(growable: false);
}

Set<String> serviceCategories(List<Salon> salons) {
  return {
    for (final salon in salons)
      for (final service in salon.services) service.category,
  };
}

bool _matchesQuery(Salon salon, String needle) {
  final haystacks = <String>[
    salon.name,
    salon.tagline,
    salon.city,
    salon.address,
    ...salon.services.map((service) => service.name),
    ...salon.services.map((service) => service.category),
    ...salon.stylists.map((stylist) => stylist.name),
  ];
  return haystacks.any((value) => value.toLowerCase().contains(needle));
}
