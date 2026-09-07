import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salon_book/core/constants/app_spacing.dart';
import 'package:salon_book/core/di/injection.dart';
import 'package:salon_book/core/utils/date_time_utils.dart';
import 'package:salon_book/core/widgets/empty_state.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/domain/repositories/booking_repository.dart';
import 'package:salon_book/domain/repositories/salon_repository.dart';
import 'package:salon_book/features/auth/presentation/auth_controller.dart';
import 'package:salon_book/features/staff/domain/staff_schedule_builder.dart';
import 'package:salon_book/features/staff/presentation/widgets/staff_booking_sheet.dart';
import 'package:salon_book/features/staff/presentation/widgets/staff_day_calendar.dart';
import 'package:table_calendar/table_calendar.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  DateTime _selectedDay = DateTimeUtils.startOfDay(DateTime.now());
  Salon? _salon;

  @override
  void initState() {
    super.initState();
    _loadSalon();
  }

  Future<void> _loadSalon() async {
    final salonId = getIt<AuthController>().user.salonId;
    if (salonId == null) return;
    final salon = await getIt<SalonRepository>().getSalonById(salonId);
    if (mounted) setState(() => _salon = salon);
  }

  void _shiftDay(int days) {
    setState(() => _selectedDay = _selectedDay.add(Duration(days: days)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = getIt<AuthController>();
    final user = auth.user;
    final salonId = user.salonId;
    final theme = Theme.of(context);

    if (salonId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: const EmptyState(
          icon: Icons.storefront_outlined,
          title: 'No salon assigned',
          message: 'This staff account is not linked to a salon yet.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) context.go('/discover');
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: StreamBuilder<List<Booking>>(
        stream: getIt<BookingRepository>().watchBySalon(salonId),
        builder: (context, snapshot) {
          final salon = _salon;
          if (salon == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final dayBookings = (snapshot.data ?? const <Booking>[])
              .where(
                (booking) =>
                    booking.status != BookingStatus.cancelled &&
                    DateTimeUtils.startOfDay(booking.start) == _selectedDay,
              )
              .toList();
          final entries = StaffScheduleBuilder.build(salon: salon, bookings: dayBookings, day: _selectedDay);
          final upcomingCount = dayBookings.where((b) => b.status == BookingStatus.upcoming).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
            children: [
              Text(
                'Hello, ${user.name.split(' ').first}',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                salon.name,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  IconButton(onPressed: () => _shiftDay(-1), icon: const Icon(Icons.chevron_left_rounded)),
                  Expanded(
                    child: Text(
                      DateTimeUtils.formatFullDate(_selectedDay),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(onPressed: () => _shiftDay(1), icon: const Icon(Icons.chevron_right_rounded)),
                ],
              ),
              TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 7)),
                lastDay: DateTime.now().add(const Duration(days: 90)),
                focusedDay: _selectedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                calendarFormat: CalendarFormat.week,
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                onDaySelected: (selected, focused) {
                  setState(() => _selectedDay = DateTimeUtils.startOfDay(selected));
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$upcomingCount upcoming · ${entries.length} total',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      if (isSameDay(_selectedDay, DateTime.now()))
                        Text(
                          'Live',
                          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (entries.isEmpty)
                const EmptyState(
                  icon: Icons.event_available_outlined,
                  title: 'Clear day',
                  message: 'New client bookings appear here automatically.',
                )
              else
                StaffDayCalendar(
                  salon: salon,
                  entries: entries,
                  onBookingTap: (entry) => showStaffBookingSheet(context, entry),
                ),
            ],
          );
        },
      ),
    );
  }
}
