import 'package:flutter/material.dart';
import 'package:salon_book/core/constants/app_spacing.dart';
import 'package:salon_book/core/di/injection.dart';
import 'package:salon_book/core/utils/date_time_utils.dart';
import 'package:salon_book/core/utils/formatters.dart';
import 'package:salon_book/core/widgets/empty_state.dart';
import 'package:salon_book/core/widgets/section_header.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/domain/repositories/salon_repository.dart';

class StartBookingScreen extends StatefulWidget {
  const StartBookingScreen({super.key, required this.salonId, required this.serviceId});

  final String salonId;
  final String? serviceId;

  @override
  State<StartBookingScreen> createState() => _StartBookingScreenState();
}

class _StartBookingScreenState extends State<StartBookingScreen> {
  String? _stylistId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Salon?>(
      future: getIt<SalonRepository>().getSalonById(widget.salonId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final salon = snapshot.data;
        SalonService? service;
        if (salon != null) {
          for (final item in salon.services) {
            if (item.id == widget.serviceId) {
              service = item;
              break;
            }
          }
        }

        if (salon == null || service == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Book')),
            body: const EmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Booking unavailable',
              message: 'That service is no longer on the menu.',
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Book')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
            children: [
              Text(
                service.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${salon.name} · ${DateTimeUtils.formatMinutes(service.durationMinutes)} · ${Formatters.inr(service.price)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(
                title: 'Stylist',
                subtitle: 'Anyone free, or someone you already know.',
              ),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ChoiceChip(
                    label: const Text('Any available'),
                    selected: _stylistId == null,
                    onSelected: (_) => setState(() => _stylistId = null),
                  ),
                  ...salon.stylists.map((stylist) {
                    return ChoiceChip(
                      label: Text(stylist.name),
                      selected: _stylistId == stylist.id,
                      onSelected: (_) => setState(() => _stylistId = stylist.id),
                    );
                  }),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Time slots arrive in Phase 2')),
                  );
                },
                child: const Text('Choose a time'),
              ),
            ],
          ),
        );
      },
    );
  }
}
