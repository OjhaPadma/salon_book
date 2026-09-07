import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:salon_book/core/notifications/appointment_notifier.dart';
import 'package:salon_book/core/notifications/local_appointment_notifier.dart';
import 'package:salon_book/data/repositories/in_memory_booking_repository.dart';
import 'package:salon_book/data/repositories/seed_auth_repository.dart';
import 'package:salon_book/data/repositories/seed_salon_repository.dart';
import 'package:salon_book/domain/repositories/auth_repository.dart';
import 'package:salon_book/domain/repositories/booking_repository.dart';
import 'package:salon_book/domain/repositories/salon_repository.dart';
import 'package:salon_book/features/auth/presentation/auth_controller.dart';
import 'package:salon_book/features/booking/domain/availability_engine.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<SalonRepository>()) return;

  getIt
    ..registerLazySingleton<AvailabilityEngine>(AvailabilityEngine.new)
    ..registerLazySingleton<SalonRepository>(SeedSalonRepository.new)
    ..registerLazySingleton<AuthRepository>(SeedAuthRepository.new)
    ..registerLazySingleton<AuthController>(() => AuthController(getIt<AuthRepository>()));

  if (!kIsWeb) {
    try {
      final notifier = await LocalAppointmentNotifier.create();
      getIt.registerSingleton<AppointmentNotifier>(notifier);
    } on Object {
      getIt.registerSingleton<AppointmentNotifier>(NoOpAppointmentNotifier());
    }
  } else {
    getIt.registerSingleton<AppointmentNotifier>(NoOpAppointmentNotifier());
  }

  getIt.registerLazySingleton<BookingRepository>(
    () => InMemoryBookingRepository(
      engine: getIt<AvailabilityEngine>(),
      notifier: getIt<AppointmentNotifier>(),
      salonRepository: getIt<SalonRepository>(),
    ),
  );
}
