import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salon_book/core/constants/app_spacing.dart';
import 'package:salon_book/core/di/injection.dart';
import 'package:salon_book/core/widgets/app_loading_indicator.dart';
import 'package:salon_book/core/widgets/empty_state.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/domain/repositories/booking_repository.dart';
import 'package:salon_book/domain/repositories/salon_repository.dart';
import 'package:salon_book/features/auth/presentation/auth_controller.dart';
import 'package:salon_book/features/appointments/domain/cancellation_policy.dart';
import 'package:salon_book/features/appointments/presentation/widgets/booking_tile.dart';

class AppointmentDetailScreen extends StatefulWidget {
  const AppointmentDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  double _rating = 5;
  final _commentController = TextEditingController();
  bool _submittingReview = false;
  bool _reviewSubmitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingRepository = getIt<BookingRepository>();
    final salonRepository = getIt<SalonRepository>();

    return FutureBuilder<Booking?>(
      future: bookingRepository.getBookingById(widget.bookingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: AppLoadingIndicator());
        }

        final booking = snapshot.data;
        if (booking == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Appointment not found',
              message: 'It may have been removed.',
            ),
          );
        }

        return FutureBuilder<List<dynamic>>(
          future: Future.wait([
            salonRepository.getSalonById(booking.salonId),
            salonRepository.hasReviewForBooking(booking.id),
          ]),
          builder: (context, metaSnapshot) {
            if (metaSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(title: const Text('Appointment')),
                body: const AppLoadingIndicator(),
              );
            }

            final salon = metaSnapshot.data?[0] as Salon?;
            final hasReview = _reviewSubmitted || (metaSnapshot.data?[1] as bool? ?? false);
            final lookup = salon == null ? const BookingLookup() : BookingLookup.from({salon.id: salon}, booking);
            final theme = Theme.of(context);
            final now = DateTime.now();

            return Scaffold(
              appBar: AppBar(title: const Text('Appointment')),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
                children: [
                  BookingTile(
                    booking: booking,
                    salon: lookup.salon,
                    service: lookup.service,
                    stylist: lookup.stylist,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (booking.status == BookingStatus.upcoming) ...[
                    Text(
                      CancellationPolicy.message(now: now, start: booking.start),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: () => context.push('/bookings/${booking.id}/reschedule'),
                      child: const Text('Reschedule'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: () => _cancel(context, booking),
                      child: const Text('Cancel appointment'),
                    ),
                  ],
                  if (booking.status == BookingStatus.completed && !hasReview) ...[
                    Text('Leave a note', style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: List.generate(5, (index) {
                        final value = index + 1;
                        return IconButton(
                          tooltip: 'Rate $value stars',
                          onPressed: () => setState(() => _rating = value.toDouble()),
                          icon: Icon(
                            value <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        );
                      }),
                    ),
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'How was the chair?'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: _submittingReview ? null : () => _submitReview(booking, lookup.salon),
                      child: Text(_submittingReview ? 'Sending…' : 'Submit review'),
                    ),
                  ],
                  if (booking.status == BookingStatus.completed && hasReview)
                    Text(
                      'Thanks — your review is on the salon profile.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _cancel(BuildContext context, Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final policy = CancellationPolicy.message(now: DateTime.now(), start: booking.start);
        return AlertDialog(
          title: const Text('Cancel appointment?'),
          content: Text(policy),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancel visit')),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await getIt<BookingRepository>().cancelBooking(booking.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment cancelled')));
      context.pop();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not cancel appointment. Try again.')),
      );
    }
  }

  Future<void> _submitReview(Booking booking, Salon? salon) async {
    if (salon == null) return;
    setState(() => _submittingReview = true);
    try {
      final author = getIt<AuthController>().user.name;
      await getIt<SalonRepository>().submitReview(
        salonId: salon.id,
        bookingId: booking.id,
        author: author,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty ? 'A quiet, good visit.' : _commentController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _submittingReview = false;
        _reviewSubmitted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _submittingReview = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit review. Try again.')),
      );
    }
  }
}
