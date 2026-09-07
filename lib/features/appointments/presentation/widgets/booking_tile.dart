import 'package:flutter/material.dart';
import 'package:salon_book/core/constants/app_spacing.dart';
import 'package:salon_book/core/utils/date_time_utils.dart';
import 'package:salon_book/domain/models/models.dart';

class BookingTile extends StatelessWidget {
  const BookingTile({super.key, required this.booking, this.salon, this.service, this.stylist, this.onTap});

  final Booking booking;
  final Salon? salon;
  final SalonService? service;
  final Stylist? stylist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = _statusLabel(booking.status);
    final label = [
      service?.name ?? 'Appointment',
      if (salon != null) 'at ${salon!.name}',
      DateTimeUtils.formatFullDate(booking.start),
    ].join(', ');

    return Semantics(
      button: onTap != null,
      label: label,
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.7)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(service?.name ?? 'Appointment', style: theme.textTheme.titleLarge),
                    ),
                    if (statusLabel != null) _statusStyle(context, statusLabel),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  salon?.name ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${DateTimeUtils.formatFullDate(booking.start)} · ${DateTimeUtils.formatTimeRange(booking.start, booking.end)}',
                  style: theme.textTheme.bodyMedium,
                ),
                if (stylist != null)
                  Text(
                    stylist!.name,
                    style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _statusLabel(BookingStatus status) {
    return switch (status) {
      BookingStatus.cancelled => 'Cancelled',
      BookingStatus.completed => 'Completed',
      BookingStatus.noShow => 'No-show',
      BookingStatus.upcoming => null,
    };
  }

  Widget _statusStyle(BuildContext context, String label) {
    final theme = Theme.of(context);
    final color = label == 'Cancelled' ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant;
    return Text(label, style: theme.textTheme.labelMedium?.copyWith(color: color));
  }
}

class BookingLookup {
  const BookingLookup({this.salon, this.service, this.stylist});

  final Salon? salon;
  final SalonService? service;
  final Stylist? stylist;

  static BookingLookup from(Map<String, Salon> salons, Booking booking) {
    final salon = salons[booking.salonId];
    SalonService? service;
    Stylist? stylist;
    if (salon != null) {
      for (final item in salon.services) {
        if (item.id == booking.serviceId) service = item;
      }
      for (final item in salon.stylists) {
        if (item.id == booking.stylistId) stylist = item;
      }
    }
    return BookingLookup(salon: salon, service: service, stylist: stylist);
  }
}
