import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:salon_book/core/constants/app_spacing.dart';
import 'package:salon_book/core/widgets/branded_header.dart';
import 'package:salon_book/core/widgets/empty_state.dart';
import 'package:salon_book/core/widgets/skeleton_box.dart';
import 'package:salon_book/features/discovery/presentation/cubit/discovery_cubit.dart';
import 'package:salon_book/features/discovery/presentation/cubit/discovery_state.dart';
import 'package:salon_book/features/discovery/presentation/widgets/filter_chips_bar.dart';
import 'package:salon_book/features/discovery/presentation/widgets/salon_card.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: context.read<DiscoveryCubit>().state.query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<DiscoveryCubit, DiscoveryState>(
          listenWhen: (previous, current) => previous.query != current.query && current.query.isEmpty,
          listener: (context, state) {
            if (state.query.isEmpty && _searchController.text.isNotEmpty) {
              _searchController.clear();
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<DiscoveryCubit>().load(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BrandedHeader(subtitle: 'Find a quiet chair.'),
                        const SizedBox(height: AppSpacing.lg),
                        TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onChanged: context.read<DiscoveryCubit>().search,
                          decoration: InputDecoration(
                            labelText: 'Search salons',
                            hintText: 'Search salons or services',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: state.query.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    onPressed: () {
                                      _searchController.clear();
                                      context.read<DiscoveryCubit>().search('');
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FilterChipsBar(state: state),
                      ],
                    ),
                  ),
                ),
                if (state.status == DiscoveryStatus.loading)
                  const SliverToBoxAdapter(child: SalonListSkeleton())
                else if (state.status == DiscoveryStatus.error)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.wifi_off_rounded,
                      title: 'Couldn’t load salons',
                      message: state.errorMessage ?? 'Check your connection and try again.',
                      action: FilledButton(
                        onPressed: () => context.read<DiscoveryCubit>().load(),
                        child: const Text('Retry'),
                      ),
                    ),
                  )
                else if (state.visible.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No salons match',
                      message: 'Try another name, service, or ease the filters.',
                      action: state.hasActiveFilters
                          ? TextButton(
                              onPressed: () => context.read<DiscoveryCubit>().clearFilters(),
                              child: const Text('Clear filters'),
                            )
                          : null,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
                    sliver: SliverList.separated(
                      itemCount: state.visible.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final salon = state.visible[index];
                        return SalonCard(
                          salon: salon,
                          onTap: () => context.push('/discover/salons/${salon.id}'),
                        );
                      },
                    ),
                  ),
              ],
              ),
            );
          },
        ),
      ),
    );
  }
}
