import 'package:get_it/get_it.dart';
import 'package:salon_book/data/repositories/seed_salon_repository.dart';
import 'package:salon_book/domain/repositories/salon_repository.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<SalonRepository>()) return;

  getIt
    ..registerLazySingleton<SalonRepository>(SeedSalonRepository.new)
    ..registerLazySingleton<BookingRepository>(InMemoryBookingRepository.new);
}
