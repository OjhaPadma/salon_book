import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:salon_book/core/di/injection.dart';
import 'package:salon_book/core/routing/app_shell.dart';
import 'package:salon_book/domain/repositories/booking_repository.dart';
import 'package:salon_book/domain/repositories/salon_repository.dart';
import 'package:salon_book/features/appointments/presentation/screens/bookings_screen.dart';
import 'package:salon_book/features/booking/domain/availability_engine.dart';
import 'package:salon_book/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:salon_book/features/booking/presentation/bloc/booking_event.dart';
import 'package:salon_book/features/booking/presentation/screens/booking_flow_screen.dart';
import 'package:salon_book/features/discovery/presentation/cubit/discovery_cubit.dart';
import 'package:salon_book/features/discovery/presentation/screens/discover_screen.dart';
import 'package:salon_book/features/discovery/presentation/screens/salon_profile_screen.dart';
import 'package:salon_book/features/profile/presentation/screens/profile_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/discover',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                builder: (context, state) => BlocProvider(
                  create: (_) => DiscoveryCubit(getIt())..load(),
                  child: const DiscoverScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'salons/:salonId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        SalonProfileScreen(salonId: state.pathParameters['salonId']!),
                    routes: [
                      GoRoute(
                        path: 'book',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => BlocProvider(
                          create: (_) => BookingBloc(
                            salonRepository: getIt<SalonRepository>(),
                            bookingRepository: getIt<BookingRepository>(),
                            engine: getIt<AvailabilityEngine>(),
                          )..add(
                            BookingStarted(
                              salonId: state.pathParameters['salonId']!,
                              serviceId: state.uri.queryParameters['serviceId'],
                            ),
                          ),
                          child: const BookingFlowScreen(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/bookings', builder: (context, state) => const BookingsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())],
          ),
        ],
      ),
    ],
  );
}
