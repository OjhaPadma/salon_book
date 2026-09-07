import 'package:go_router/go_router.dart';
import 'package:salon_book/core/routing/app_shell.dart';
import 'package:salon_book/features/appointments/presentation/screens/bookings_screen.dart';
import 'package:salon_book/features/discovery/presentation/screens/discover_screen.dart';
import 'package:salon_book/features/profile/presentation/screens/profile_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/discover',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/discover', builder: (context, state) => const DiscoverScreen())],
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
