import 'package:flutter/material.dart';
import 'package:salon_book/core/constants/app_spacing.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, required this.height, this.width, this.radius = 12});

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class SalonListSkeleton extends StatelessWidget {
  const SalonListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
      child: Column(
        children: [
          SkeletonBox(height: 220, radius: 20),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(height: 220, radius: 20),
        ],
      ),
    );
  }
}
