import 'package:flutter/material.dart';
import 'package:salon_book/core/utils/date_time_utils.dart';
import 'package:salon_book/domain/models/time_slot.dart';

class TimeSlotGrid extends StatelessWidget {
  const TimeSlotGrid({super.key, required this.slots, required this.selected, required this.onSelected});

  final List<TimeSlot> slots;
  final TimeSlot? selected;
  final ValueChanged<TimeSlot> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final slot in slots)
          ChoiceChip(
            key: ValueKey(slot.id),
            label: Text(DateTimeUtils.formatTime(slot.start)),
            selected: selected?.id == slot.id,
            onSelected: (_) => onSelected(slot),
          ),
      ],
    );
  }
}
