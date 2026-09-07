import 'package:flutter/material.dart';
import 'package:salon_book/core/constants/app_spacing.dart';
import 'package:salon_book/core/widgets/network_image_frame.dart';
import 'package:salon_book/core/widgets/rating_badge.dart';
import 'package:salon_book/domain/models/salon.dart';

class SalonCard extends StatelessWidget {
  const SalonCard({super.key, required this.salon, this.onTap});

  final Salon salon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetworkImageFrame(
              url: salon.coverUrl,
              height: 168,
              width: double.infinity,
              borderRadius: 0,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          salon.name,
                          style: theme.textTheme.titleLarge?.copyWith(letterSpacing: -0.4),
                        ),
                      ),
                      RatingBadge(rating: salon.rating),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    salon.tagline,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${salon.city} · ${salon.services.length} services',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
