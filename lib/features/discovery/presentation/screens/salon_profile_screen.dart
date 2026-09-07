import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salon_book/core/constants/app_spacing.dart';
import 'package:salon_book/core/di/injection.dart';
import 'package:salon_book/core/utils/date_time_utils.dart';
import 'package:salon_book/core/utils/formatters.dart';
import 'package:salon_book/core/widgets/app_loading_indicator.dart';
import 'package:salon_book/core/widgets/empty_state.dart';
import 'package:salon_book/core/widgets/network_image_frame.dart';
import 'package:salon_book/core/widgets/rating_badge.dart';
import 'package:salon_book/core/widgets/section_header.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/domain/repositories/salon_repository.dart';

class SalonProfileScreen extends StatefulWidget {
  const SalonProfileScreen({super.key, required this.salonId});

  final String salonId;

  @override
  State<SalonProfileScreen> createState() => _SalonProfileScreenState();
}

class _SalonProfileScreenState extends State<SalonProfileScreen> {
  late Future<Salon?> _salonFuture;

  @override
  void initState() {
    super.initState();
    _salonFuture = getIt<SalonRepository>().getSalonById(widget.salonId);
  }

  void _reload() {
    setState(() => _salonFuture = getIt<SalonRepository>().getSalonById(widget.salonId));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Salon?>(
      future: _salonFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.wifi_off_rounded,
              title: "Couldn't load salon",
              message: 'Check your connection and try again.',
              action: FilledButton(onPressed: _reload, child: const Text('Retry')),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: AppLoadingIndicator());
        }

        final salon = snapshot.data;
        if (salon == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icon: Icons.storefront_outlined,
              title: 'Salon not found',
              message: 'It may have moved or the link is out of date.',
            ),
          );
        }

        final contentWidth = MediaQuery.sizeOf(context).width - (AppSpacing.lg * 2);

        return Scaffold(
          appBar: AppBar(title: Text(salon.name)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
            children: [
              NetworkImageFrame(
                url: salon.coverUrl,
                height: 200,
                width: contentWidth,
                borderRadius: AppSpacing.radius,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      salon.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  RatingBadge(rating: salon.rating),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                salon.tagline,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${salon.address}, ${salon.city} · ${salon.reviewCount} reviews',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Services'),
              ...salon.services.map((service) => _ServiceTile(salonId: salon.id, service: service)),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Stylists'),
              ...salon.stylists.map(_StylistTile.new),
              if (salon.galleryUrls.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(title: 'Gallery'),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: salon.galleryUrls.length,
                    separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      return NetworkImageFrame(
                        url: salon.galleryUrls[index],
                        height: 120,
                        width: 160,
                        borderRadius: AppSpacing.radiusSm,
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: 'Reviews',
                subtitle: salon.reviews.isEmpty ? null : '${salon.reviews.length} recent',
              ),
              if (salon.reviews.isEmpty)
                const EmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'No reviews yet',
                  message: 'Be the first to leave a note after your appointment.',
                )
              else
                ...salon.reviews.map(_ReviewTile.new),
            ],
          ),
        );
      },
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.salonId, required this.service});

  final String salonId;
  final SalonService service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.7)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(service.name, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '${service.category} · ${DateTimeUtils.formatMinutes(service.durationMinutes)} · ${Formatters.inr(service.price)}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                key: ValueKey('book-${service.id}'),
                onPressed: () =>
                    context.push('/discover/salons/$salonId/book?serviceId=${service.id}'),
                child: const Text('Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StylistTile extends StatelessWidget {
  const _StylistTile(this.stylist);

  final Stylist stylist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NetworkImageFrame(
            url: stylist.photoUrl,
            height: 56,
            width: 56,
            borderRadius: 28,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stylist.name, style: theme.textTheme.titleMedium),
                Text(
                  stylist.title,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  stylist.bio,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile(this.review);

  final Review review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(review.author, style: theme.textTheme.titleSmall)),
              RatingBadge(rating: review.rating),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            review.comment,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
