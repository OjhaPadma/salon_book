import 'package:flutter/material.dart';
import 'package:salon_book/core/widgets/skeleton_box.dart';

class NetworkImageFrame extends StatelessWidget {
  const NetworkImageFrame({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.borderRadius = 16,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double? height;
  final double? width;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final fallbackColor = Theme.of(context).colorScheme.outlineVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedWidth = width ?? (constraints.maxWidth.isFinite ? constraints.maxWidth : 400);

        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.network(
            url,
            height: height,
            width: resolvedWidth,
            fit: fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SkeletonBox(
                height: height ?? 120,
                width: resolvedWidth,
                radius: borderRadius,
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return ColoredBox(
                color: fallbackColor,
                child: SizedBox(
                  height: height,
                  width: resolvedWidth,
                  child: Icon(
                    Icons.spa_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
