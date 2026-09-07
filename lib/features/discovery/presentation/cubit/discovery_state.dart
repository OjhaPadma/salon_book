import 'package:equatable/equatable.dart';
import 'package:salon_book/domain/models/salon.dart';
import 'package:salon_book/features/discovery/domain/filter_salons.dart';

enum DiscoveryStatus { loading, ready, error }

class DiscoveryState extends Equatable {
  const DiscoveryState({
    required this.status,
    required this.salons,
    required this.query,
    this.category,
    this.minRating,
    this.errorMessage,
  });

  const DiscoveryState.initial()
    : status = DiscoveryStatus.loading,
      salons = const [],
      query = '',
      category = null,
      minRating = null,
      errorMessage = null;

  final DiscoveryStatus status;
  final List<Salon> salons;
  final String query;
  final String? category;
  final double? minRating;
  final String? errorMessage;

  List<String> get categories {
    final values = serviceCategories(salons).toList()..sort();
    return values;
  }

  List<Salon> get visible => filterSalons(
    salons: salons,
    query: query,
    category: category,
    minRating: minRating,
  );

  bool get hasActiveFilters => query.trim().isNotEmpty || category != null || minRating != null;

  DiscoveryState copyWith({
    DiscoveryStatus? status,
    List<Salon>? salons,
    String? query,
    String? category,
    double? minRating,
    String? errorMessage,
    bool clearCategory = false,
    bool clearMinRating = false,
  }) {
    return DiscoveryState(
      status: status ?? this.status,
      salons: salons ?? this.salons,
      query: query ?? this.query,
      category: clearCategory ? null : category ?? this.category,
      minRating: clearMinRating ? null : minRating ?? this.minRating,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, salons, query, category, minRating, errorMessage];
}
