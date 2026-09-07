import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_book/features/discovery/presentation/cubit/discovery_cubit.dart';
import 'package:salon_book/features/discovery/presentation/cubit/discovery_state.dart';

class FilterChipsBar extends StatelessWidget {
  const FilterChipsBar({super.key, required this.state});

  final DiscoveryState state;

  static const _ratings = <double?>[null, 4.5, 4.8];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DiscoveryCubit>();
    final chips = <Widget>[
      for (final category in ['All', ...state.categories])
        FilterChip(
          label: Text(category),
          selected: category == 'All' ? state.category == null : state.category == category,
          onSelected: (_) {
            cubit.selectCategory(category == 'All' ? null : category);
          },
        ),
      ..._ratings.map((rating) {
        final label = rating == null ? 'Any rating' : '${rating.toStringAsFixed(1)}+';
        return FilterChip(
          label: Text(label),
          selected: state.minRating == rating,
          onSelected: (_) => cubit.selectMinRating(rating),
        );
      }),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            chips[i],
          ],
        ],
      ),
    );
  }
}
