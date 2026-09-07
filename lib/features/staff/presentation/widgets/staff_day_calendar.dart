import 'package:flutter/material.dart';
import 'package:salon_book/core/constants/app_spacing.dart';
import 'package:salon_book/core/theme/app_colors.dart';
import 'package:salon_book/core/utils/date_time_utils.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/features/staff/domain/staff_schedule_builder.dart';

class StaffDayCalendar extends StatelessWidget {
  const StaffDayCalendar({
    super.key,
    required this.salon,
    required this.entries,
    required this.onBookingTap,
  });

  final Salon salon;
  final List<StaffScheduleEntry> entries;
  final ValueChanged<StaffScheduleEntry> onBookingTap;

  static const _hourHeight = 52.0;
  static const _startHour = 9;
  static const _endHour = 19;

  @override
  Widget build(BuildContext context) {
    final totalHours = _endHour - _startHour;
    final gridHeight = totalHours * _hourHeight;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimeAxis(height: gridHeight),
          ...salon.stylists.map((stylist) {
            final stylistEntries = entries.where((entry) => entry.stylist.id == stylist.id).toList();
            return _StylistColumn(
              stylist: stylist,
              entries: stylistEntries,
              height: gridHeight,
              onBookingTap: onBookingTap,
            );
          }),
        ],
      ),
    );
  }
}

class _TimeAxis extends StatelessWidget {
  const _TimeAxis({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 52,
      height: height,
      child: Column(
        children: [
          for (var hour = StaffDayCalendar._startHour; hour < StaffDayCalendar._endHour; hour++)
            SizedBox(
              height: StaffDayCalendar._hourHeight,
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm, top: 2),
                  child: Text(
                    DateTimeUtils.formatTime(DateTime(2026, 1, 1, hour)),
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StylistColumn extends StatelessWidget {
  const _StylistColumn({
    required this.stylist,
    required this.entries,
    required this.height,
    required this.onBookingTap,
  });

  final Stylist stylist;
  final List<StaffScheduleEntry> entries;
  final double height;
  final ValueChanged<StaffScheduleEntry> onBookingTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 156,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              stylist.name.split(' ').first,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: height,
            child: Stack(
              children: [
                for (var hour = StaffDayCalendar._startHour; hour < StaffDayCalendar._endHour; hour++)
                  Positioned(
                    top: (hour - StaffDayCalendar._startHour) * StaffDayCalendar._hourHeight,
                    left: 0,
                    right: 0,
                    child: Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                for (final entry in entries) _BookingBlock(entry: entry, onTap: () => onBookingTap(entry)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingBlock extends StatelessWidget {
  const _BookingBlock({required this.entry, required this.onTap});

  final StaffScheduleEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startMinutes = entry.booking.start.hour * 60 + entry.booking.start.minute;
    final dayStartMinutes = StaffDayCalendar._startHour * 60;
    final durationMinutes = entry.booking.end.difference(entry.booking.start).inMinutes;
    final top = ((startMinutes - dayStartMinutes) / 60) * StaffDayCalendar._hourHeight;
    final height = (durationMinutes / 60) * StaffDayCalendar._hourHeight;

    final color = switch (entry.booking.status) {
      BookingStatus.upcoming => AppColors.terracotta.withValues(alpha: 0.14),
      BookingStatus.completed => AppColors.gold.withValues(alpha: 0.18),
      BookingStatus.noShow => theme.colorScheme.errorContainer.withValues(alpha: 0.35),
      BookingStatus.cancelled => theme.colorScheme.surfaceContainerHighest,
    };

    return Positioned(
      top: top.clamp(0, double.infinity),
      left: 4,
      right: 4,
      height: height.clamp(44, double.infinity),
      child: Material(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.6)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateTimeUtils.formatTime(entry.booking.start),
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  entry.service?.name ?? 'Appointment',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  entry.clientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
