import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salon_book/core/constants/app_spacing.dart';
import 'package:salon_book/core/di/injection.dart';
import 'package:salon_book/core/utils/date_time_utils.dart';
import 'package:salon_book/core/widgets/empty_state.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/domain/repositories/booking_repository.dart';
import 'package:salon_book/domain/repositories/salon_repository.dart';
import 'package:salon_book/features/auth/presentation/auth_controller.dart';

class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = getIt<AuthController>();
    final user = auth.user;
    final salonId = user.salonId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) context.go('/discover');
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: salonId == null
          ? const EmptyState(
              icon: Icons.storefront_outlined,
              title: 'No salon assigned',
              message: 'This staff account is not linked to a salon yet.',
            )
          : FutureBuilder<(Salon?, List<Booking>)>(
              future: _load(salonId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final salon = snapshot.data?.$1;
                final today = snapshot.data?.$2 ?? const <Booking>[];
                final theme = Theme.of(context);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
                  children: [
                    Text(
                      'Hello, ${user.name.split(' ').first}',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      salon?.name ?? 'Your salon',
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${today.length}', style: theme.textTheme.displaySmall),
                            Text(
                              today.length == 1 ? 'booking today' : 'bookings today',
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (today.isEmpty)
                      const EmptyState(
                        icon: Icons.event_available_outlined,
                        title: 'Clear day',
                        message: 'No client bookings on the calendar yet.',
                      )
                    else
                      ...today.map((booking) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.7)),
                            ),
                            tileColor: theme.colorScheme.surface,
                            title: Text(DateTimeUtils.formatTimeRange(booking.start, booking.end)),
                            subtitle: Text(DateTimeUtils.formatFullDate(booking.start)),
                          ),
                        );
                      }),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Full staff calendar arrives in Phase 5.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Future<(Salon?, List<Booking>)> _load(String salonId) async {
    final salon = await getIt<SalonRepository>().getSalonById(salonId);
    final bookings = await getIt<BookingRepository>().getBookings();
    final today = DateTimeUtils.startOfDay(DateTime.now());
    final salonBookings = bookings
        .where(
          (booking) =>
              booking.salonId == salonId &&
              booking.status == BookingStatus.upcoming &&
              DateTimeUtils.startOfDay(booking.start) == today,
        )
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return (salon, salonBookings);
  }
}
