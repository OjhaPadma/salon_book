import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salon_book/core/constants/app_spacing.dart';
import 'package:salon_book/core/di/injection.dart';
import 'package:salon_book/core/widgets/app_loading_indicator.dart';
import 'package:salon_book/features/auth/presentation/auth_controller.dart';
import 'package:salon_book/core/widgets/empty_state.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/domain/repositories/booking_repository.dart';
import 'package:salon_book/domain/repositories/salon_repository.dart';
import 'package:salon_book/features/appointments/presentation/widgets/booking_tile.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: StreamBuilder<List<Booking>>(
          stream: getIt<BookingRepository>().watchByClient(getIt<AuthController>().clientId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const AppLoadingIndicator();
            }

            final bookings = snapshot.data ?? const <Booking>[];
            return FutureBuilder<List<Salon>>(
              future: getIt<SalonRepository>().getSalons(),
              builder: (context, salonSnapshot) {
                if (salonSnapshot.connectionState == ConnectionState.waiting && !salonSnapshot.hasData) {
                  return const AppLoadingIndicator();
                }

                final salons = {for (final salon in salonSnapshot.data ?? const <Salon>[]) salon.id: salon};
                final upcoming = bookings
                    .where((booking) => booking.status == BookingStatus.upcoming)
                    .toList()
                  ..sort((a, b) => a.start.compareTo(b.start));
                final past = bookings
                    .where((booking) => booking.status != BookingStatus.upcoming)
                    .toList()
                  ..sort((a, b) => b.start.compareTo(a.start));

                return TabBarView(
                  children: [
                    _BookingList(
                      emptyTitle: 'No appointments yet',
                      emptyMessage: 'When you book a chair, it will appear here.',
                      bookings: upcoming,
                      salons: salons,
                    ),
                    _BookingList(
                      emptyTitle: 'Nothing in the past',
                      emptyMessage: 'Completed and cancelled visits will show up here.',
                      bookings: past,
                      salons: salons,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({
    required this.emptyTitle,
    required this.emptyMessage,
    required this.bookings,
    required this.salons,
  });

  final String emptyTitle;
  final String emptyMessage;
  final List<Booking> bookings;
  final Map<String, Salon> salons;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return EmptyState(
        icon: Icons.event_available_outlined,
        title: emptyTitle,
        message: emptyMessage,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final lookup = BookingLookup.from(salons, booking);
        return BookingTile(
          booking: booking,
          salon: lookup.salon,
          service: lookup.service,
          stylist: lookup.stylist,
          onTap: () => context.push('/bookings/${booking.id}'),
        );
      },
    );
  }
}
