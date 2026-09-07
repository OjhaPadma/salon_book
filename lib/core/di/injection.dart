import 'package:get_it/get_it.dart';
import 'package:salon_book/data/repositories/in_memory_booking_repository.dart';
import 'package:salon_book/data/repositories/seed_salon_repository.dart';
import 'package:salon_book/domain/repositories/booking_repository.dart';
import 'package:salon_book/domain/repositories/salon_repository.dart';
import 'package:salon_book/features/booking/domain/availability_engine.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<SalonRepository>()) return;

  getIt
    ..registerLazySingleton<AvailabilityEngine>(AvailabilityEngine.new)
    ..registerLazySingleton<SalonRepository>(SeedSalonRepository.new)
    ..registerLazySingleton<BookingRepository>(
      () => InMemoryBookingRepository(engine: getIt<AvailabilityEngine>()),
    );
}
