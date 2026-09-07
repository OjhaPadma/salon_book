import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:salon_book/core/constants/app_spacing.dart';
import 'package:salon_book/core/theme/app_colors.dart';
import 'package:salon_book/core/utils/date_time_utils.dart';
import 'package:salon_book/core/utils/formatters.dart';
import 'package:salon_book/core/widgets/empty_state.dart';
import 'package:salon_book/core/widgets/section_header.dart';
import 'package:salon_book/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:salon_book/features/booking/presentation/bloc/booking_event.dart';
import 'package:salon_book/features/booking/presentation/bloc/booking_state.dart';
import 'package:salon_book/features/booking/presentation/widgets/time_slot_grid.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingFlowScreen extends StatelessWidget {
  const BookingFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
      listenWhen: (previous, current) =>
          previous.conflictMessage != current.conflictMessage && current.conflictMessage != null,
      listener: (context, state) {
        final message = state.conflictMessage;
        if (message == null) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state.salon == null || state.service == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Book')),
            body: EmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Booking unavailable',
              message: state.errorMessage ?? 'That service is no longer on the menu.',
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_title(state.step, isRescheduling: state.isRescheduling)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (state.step == BookingStep.stylist || state.step == BookingStep.success) {
                  context.pop();
                } else {
                  context.read<BookingBloc>().add(const BookingBack());
                }
              },
            ),
          ),
          body: switch (state.step) {
            BookingStep.stylist when !state.isRescheduling => _StylistStep(state: state),
            BookingStep.stylist => _ScheduleStep(state: state),
            BookingStep.schedule => _ScheduleStep(state: state),
            BookingStep.confirm => _ConfirmStep(state: state),
            BookingStep.success => _SuccessStep(state: state),
          },
        );
      },
    );
  }

  String _title(BookingStep step, {required bool isRescheduling}) {
    return switch (step) {
      BookingStep.stylist => isRescheduling ? 'Reschedule' : 'Book',
      BookingStep.schedule => 'Time',
      BookingStep.confirm => isRescheduling ? 'Confirm change' : 'Confirm',
      BookingStep.success => isRescheduling ? 'Updated' : 'Booked',
    };
  }
}

class _StylistStep extends StatelessWidget {
  const _StylistStep({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    final salon = state.salon!;
    final service = state.service!;
    final bloc = context.read<BookingBloc>();

    return ListView(
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
              selected: state.preferredStylistId == null,
              onSelected: (_) => bloc.add(const BookingStylistChosen(null)),
            ),
            ...salon.stylists.map((stylist) {
              return ChoiceChip(
                label: Text(stylist.name),
                selected: state.preferredStylistId == stylist.id,
                onSelected: (_) => bloc.add(BookingStylistChosen(stylist.id)),
              );
            }),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: () => bloc.add(const BookingContinueToSchedule()),
          child: const Text('Choose a time'),
        ),
      ],
    );
  }
}

class _ScheduleStep extends StatelessWidget {
  const _ScheduleStep({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<BookingBloc>();
    final selectedDay = state.selectedDay ?? DateTime.now();
    final today = DateTimeUtils.startOfDay(DateTime.now());

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            children: [
              TableCalendar(
                firstDay: today,
                lastDay: today.add(const Duration(days: 90)),
                focusedDay: selectedDay.isBefore(today) ? today : selectedDay,
                selectedDayPredicate: (day) => isSameDay(day, selectedDay),
                calendarFormat: CalendarFormat.twoWeeks,
                availableGestures: AvailableGestures.horizontalSwipe,
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.terracotta,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.terracotta),
                  ),
                  todayTextStyle: theme.textTheme.bodyMedium!,
                ),
                onDaySelected: (selected, focused) => bloc.add(BookingDayChosen(selected)),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(title: 'Available times'),
              if (state.slots.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: EmptyState(
                    icon: Icons.hourglass_empty_rounded,
                    title: 'No times this day',
                    message: 'The chair is full, or the salon is closed. Try another date.',
                  ),
                )
              else
                TimeSlotGrid(
                  slots: state.slots,
                  selected: state.selectedSlot,
                  onSelected: (slot) => bloc.add(BookingSlotChosen(slot)),
                ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
            child: FilledButton(
              onPressed: state.selectedSlot == null
                  ? null
                  : () => bloc.add(const BookingContinueToConfirm()),
              child: const Text('Review booking'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmStep extends StatelessWidget {
  const _ConfirmStep({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    final salon = state.salon!;
    final service = state.service!;
    final slot = state.selectedSlot!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
      children: [
        Text(
          state.isRescheduling ? 'Pick a new time' : 'Does this look right?',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SummaryRow(label: 'Salon', value: salon.name),
        _SummaryRow(label: 'Service', value: service.name),
        _SummaryRow(label: 'Stylist', value: state.stylistLabel),
        _SummaryRow(label: 'When', value: DateTimeUtils.formatTimeRange(slot.start, slot.end)),
        _SummaryRow(label: 'Date', value: DateTimeUtils.formatFullDate(slot.start)),
        _SummaryRow(label: 'Duration', value: DateTimeUtils.formatMinutes(service.durationMinutes)),
        _SummaryRow(label: 'Total', value: Formatters.inr(service.price)),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Payment stays off for now. Confirm to hold the chair.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: state.isSubmitting ? null : () => context.read<BookingBloc>().add(const BookingSubmitted()),
          child: Text(state.isSubmitting ? 'Saving…' : state.isRescheduling ? 'Confirm change' : 'Confirm booking'),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(child: Text(value, style: theme.textTheme.titleMedium)),
        ],
      ),
    );
  }
}

class _SuccessStep extends StatelessWidget {
  const _SuccessStep({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    final booking = state.confirmedBooking;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 56, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            state.isRescheduling ? 'Your appointment moved.' : 'You’re booked.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (booking != null)
            Text(
              DateTimeUtils.formatTimeRange(booking.start, booking.end),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: () => context.go('/bookings'),
            child: const Text('View bookings'),
          ),
        ],
      ),
    );
  }
}
