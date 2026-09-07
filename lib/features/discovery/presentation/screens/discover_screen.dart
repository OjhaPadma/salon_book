import 'package:flutter/material.dart';
import 'package:salon_book/core/constants/app_spacing.dart';
import 'package:salon_book/core/di/injection.dart';
import 'package:salon_book/domain/models/salon.dart';
import 'package:salon_book/domain/repositories/salon_repository.dart';
import 'package:salon_book/features/discovery/presentation/widgets/salon_card.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late final Future<List<Salon>> _salonsFuture = getIt<SalonRepository>().getSalons();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Salon>>(
          future: _salonsFuture,
          builder: (context, snapshot) {
            final salons = snapshot.data ?? const <Salon>[];

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GlamSlot',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Find a quiet chair.',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'Search salons or services',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: Icon(
                              Icons.tune_rounded,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
                    sliver: SliverList.separated(
                      itemCount: salons.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        return SalonCard(salon: salons[index]);
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
