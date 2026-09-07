import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_book/domain/repositories/salon_repository.dart';
import 'package:salon_book/features/discovery/presentation/cubit/discovery_state.dart';

class DiscoveryCubit extends Cubit<DiscoveryState> {
  DiscoveryCubit(this._repository) : super(const DiscoveryState.initial());

  final SalonRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: DiscoveryStatus.loading));
    try {
      final salons = await _repository.getSalons();
      emit(state.copyWith(status: DiscoveryStatus.ready, salons: salons));
    } on Object catch (error) {
      emit(state.copyWith(status: DiscoveryStatus.error, errorMessage: error.toString()));
    }
  }

  void search(String query) => emit(state.copyWith(query: query));

  void selectCategory(String? category) {
    emit(state.copyWith(category: category, clearCategory: category == null));
  }

  void selectMinRating(double? minRating) {
    emit(state.copyWith(minRating: minRating, clearMinRating: minRating == null));
  }

  void clearFilters() {
    emit(state.copyWith(query: '', clearCategory: true, clearMinRating: true));
  }
}
