import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
    required this.id,
    required this.salonId,
    required this.author,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String salonId;
  final String author;
  final double rating;
  final String comment;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, salonId, author, rating, comment, createdAt];
}
