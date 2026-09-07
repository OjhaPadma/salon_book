import 'package:flutter/material.dart';
import 'package:salon_book/core/constants/app_spacing.dart';

class BrandedHeader extends StatelessWidget {
  const BrandedHeader({super.key, required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
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
          subtitle,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: subtitle.length > 20 ? -0.8 : 0,
          ),
        ),
      ],
    );
  }
}
