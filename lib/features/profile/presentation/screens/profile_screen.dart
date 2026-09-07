import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salon_book/core/constants/app_spacing.dart';
import 'package:salon_book/core/di/injection.dart';
import 'package:salon_book/core/widgets/app_card.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/domain/repositories/booking_repository.dart';
import 'package:salon_book/features/auth/presentation/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = getIt<AuthController>();
    final theme = Theme.of(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListenableBuilder(
        listenable: auth,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
            children: [
              AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                      child: Text(user.initials, style: theme.textTheme.titleLarge),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: theme.textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text(
                            user.isGuest
                                ? 'Browsing as guest'
                                : '${user.email} · ${_roleLabel(user.role)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (!user.isGuest && user.isClient) _UpcomingCountCard(clientId: auth.clientId),
              if (user.isGuest)
                FilledButton(
                  onPressed: () => context.push('/login'),
                  child: const Text('Sign in'),
                )
              else
                OutlinedButton(
                  onPressed: () async {
                    await auth.signOut();
                    if (context.mounted) context.go('/discover');
                  },
                  child: const Text('Sign out'),
                ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  children: [
                    _ProfileRow(
                      icon: Icons.notifications_none_rounded,
                      label: 'Reminders',
                      value: user.isGuest ? 'Sign in to manage' : 'On',
                    ),
                    Divider(height: AppSpacing.lg, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                    _ProfileRow(
                      icon: Icons.favorite_border_rounded,
                      label: 'Saved salons',
                      value: '—',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _roleLabel(UserRole role) {
    return switch (role) {
      UserRole.client => 'Client',
      UserRole.staff => 'Staff',
      UserRole.guest => 'Guest',
    };
  }
}

class _UpcomingCountCard extends StatelessWidget {
  const _UpcomingCountCard({required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Booking>>(
      future: getIt<BookingRepository>().getBookings(clientId: clientId),
      builder: (context, snapshot) {
        final count = (snapshot.data ?? const <Booking>[])
            .where((booking) => booking.status == BookingStatus.upcoming)
            .length;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: AppCard(
            child: Row(
              children: [
                Expanded(child: Text('Upcoming appointments', style: Theme.of(context).textTheme.titleMedium)),
                Text('$count', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
