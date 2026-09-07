import 'package:flutter/material.dart';
import 'package:salon_book/core/constants/app_spacing.dart';
import 'package:salon_book/core/di/injection.dart';
import 'package:salon_book/core/utils/date_time_utils.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/domain/repositories/booking_repository.dart';
import 'package:salon_book/features/staff/domain/staff_schedule_builder.dart';

Future<void> showStaffBookingSheet(BuildContext context, StaffScheduleEntry entry) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => _StaffBookingSheet(entry: entry),
  );
}

class _StaffBookingSheet extends StatefulWidget {
  const _StaffBookingSheet({required this.entry});

  final StaffScheduleEntry entry;

  @override
  State<_StaffBookingSheet> createState() => _StaffBookingSheetState();
}

class _StaffBookingSheetState extends State<_StaffBookingSheet> {
  bool _busy = false;

  Future<void> _update(Future<Booking> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final booking = entry.booking;
    final theme = Theme.of(context);
    final repo = getIt<BookingRepository>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(entry.service?.name ?? 'Appointment', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${DateTimeUtils.formatFullDate(booking.start)} · ${DateTimeUtils.formatTimeRange(booking.start, booking.end)}',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('${entry.clientName} · ${entry.stylist.name}', style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.lg),
          if (booking.status == BookingStatus.upcoming) ...[
            FilledButton(
              onPressed: _busy ? null : () => _update(() => repo.markCompleted(booking.id)),
              child: Text(_busy ? 'Saving…' : 'Mark complete'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: _busy ? null : () => _update(() => repo.markNoShow(booking.id)),
              child: const Text('Mark no-show'),
            ),
          ] else
            Text(
              booking.status == BookingStatus.completed
                  ? 'Completed — client can leave a review.'
                  : 'Marked as no-show.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}
