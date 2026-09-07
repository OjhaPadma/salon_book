import 'package:flutter_test/flutter_test.dart';
import 'package:salon_book/data/seed/seed_salons.dart';
import 'package:salon_book/features/discovery/domain/filter_salons.dart';

void main() {
  test('empty query returns every salon', () {
    expect(filterSalons(salons: seedSalons), hasLength(seedSalons.length));
  });

  test('query matches salon name and service', () {
    final byName = filterSalons(salons: seedSalons, query: 'quiet chair');
    expect(byName, hasLength(1));
    expect(byName.first.name, 'The Quiet Chair');

    final byService = filterSalons(salons: seedSalons, query: 'balayage');
    expect(byService.map((salon) => salon.id), ['salon-bloom']);
  });

  test('category and rating filters combine', () {
    final color = filterSalons(salons: seedSalons, category: 'Color');
    expect(color.map((salon) => salon.id), ['salon-noor', 'salon-bloom']);

    final high = filterSalons(salons: seedSalons, minRating: 4.8);
    expect(high.map((salon) => salon.id), ['salon-noor', 'salon-quiet']);
  });
}
