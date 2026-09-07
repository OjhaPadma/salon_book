import 'package:equatable/equatable.dart';

class SalonService extends Equatable {
  const SalonService({
    required this.id,
    required this.salonId,
    required this.name,
    required this.category,
    required this.durationMinutes,
    required this.price,
    required this.description,
  });

  final String id;
  final String salonId;
  final String name;
  final String category;
  final int durationMinutes;
  final double price;
  final String description;

  @override
  List<Object?> get props => [id, salonId, name, category, durationMinutes, price, description];
}
