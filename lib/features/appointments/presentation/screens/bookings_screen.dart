import 'package:flutter/material.dart';
import 'package:salon_book/core/constants/app_spacing.dart';
import 'package:salon_book/core/constants/app_user.dart';
import 'package:salon_book/core/di/injection.dart';
import 'package:salon_book/core/utils/date_time_utils.dart';
import 'package:salon_book/core/widgets/empty_state.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/domain/repositories/booking_repository.dart';
import 'package:salon_book/domain/repositories/salon_repository.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingRepository = getIt<BookingRepository>();
    final salonRepository = getIt<SalonRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: StreamBuilder<List<Booking>>(
        stream: bookingRepository.watchByClient(AppUser.guestClientId),
        builder: (context, snapshot) {
          final bookings = snapshot.data ?? const <Booking>[];
          if (bookings.isEmpty) {
            return const EmptyState(
              icon: Icons.event_available_outlined,
              title: 'No appointments yet',
              message: 'When you book a chair, it will appear here — upcoming first, then the past.',
            );
          }

          final upcoming = bookings.where((booking) => booking.status == BookingStatus.upcoming).toList()
            ..sort((a, b) => a.start.compareTo(b.start));

          return FutureBuilder<List<Salon>>(
            future: salonRepository.getSalons(),
            builder: (context, salonSnapshot) {
              final salons = {for (final salon in salonSnapshot.data ?? const <Salon>[]) salon.id: salon};

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
                itemCount: upcoming.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final booking = upcoming[index];
                  final salon = salons[booking.salonId];
                  SalonService? service;
                  Stylist? stylist;
                  if (salon != null) {
                    for (final item in salon.services) {
                      if (item.id == booking.serviceId) service = item;
                    }
                    for (final item in salon.stylists) {
                      if (item.id == booking.stylistId) stylist = item;
                    }
                  }

                  return Material(
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                      side: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.7)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service?.name ?? 'Appointment', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text(
                            salon?.name ?? '',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${DateTimeUtils.formatFullDate(booking.start)} · ${DateTimeUtils.formatTimeRange(booking.start, booking.end)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (stylist != null)
                            Text(
                              stylist.name,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
