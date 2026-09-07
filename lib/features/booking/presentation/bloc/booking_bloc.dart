import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_book/core/constants/app_user.dart';
import 'package:salon_book/core/utils/date_time_utils.dart';
import 'package:salon_book/domain/models/models.dart';
import 'package:salon_book/domain/repositories/booking_repository.dart';
import 'package:salon_book/domain/repositories/salon_repository.dart';
import 'package:salon_book/features/booking/domain/availability_engine.dart';
import 'package:salon_book/features/booking/domain/booking_conflict_exception.dart';
import 'package:salon_book/features/booking/presentation/bloc/booking_event.dart';
import 'package:salon_book/features/booking/presentation/bloc/booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc({
    required this.salonRepository,
    required this.bookingRepository,
    this.engine = const AvailabilityEngine(),
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now,
       super(const BookingState()) {
    on<BookingStarted>(_onStarted);
    on<BookingRescheduleStarted>(_onRescheduleStarted);
    on<BookingStylistChosen>(_onStylistChosen);
    on<BookingContinueToSchedule>(_onContinueToSchedule);
    on<BookingDayChosen>(_onDayChosen);
    on<BookingSlotChosen>(_onSlotChosen);
    on<BookingContinueToConfirm>(_onContinueToConfirm);
    on<BookingSubmitted>(_onSubmitted);
    on<BookingBack>(_onBack);
  }

  final SalonRepository salonRepository;
  final BookingRepository bookingRepository;
  final AvailabilityEngine engine;
  final DateTime Function() clock;

  Future<void> _onStarted(BookingStarted event, Emitter<BookingState> emit) async {
    emit(const BookingState(isLoading: true));
    final salon = await salonRepository.getSalonById(event.salonId);
    SalonService? service;
    if (salon != null && event.serviceId != null) {
      for (final item in salon.services) {
        if (item.id == event.serviceId) {
          service = item;
          break;
        }
      }
    }
    if (salon == null || service == null) {
      emit(const BookingState(isLoading: false, errorMessage: 'That service is no longer on the menu.'));
      return;
    }
    emit(
      BookingState(
        isLoading: false,
        salon: salon,
        service: service,
        selectedDay: engine.firstOpenDay(salon.stylists, from: clock()),
      ),
    );
  }

  Future<void> _onRescheduleStarted(BookingRescheduleStarted event, Emitter<BookingState> emit) async {
    emit(const BookingState(isLoading: true));
    final booking = await bookingRepository.getBookingById(event.bookingId);
    if (booking == null || booking.status != BookingStatus.upcoming) {
      emit(const BookingState(isLoading: false, errorMessage: 'That appointment cannot be rescheduled.'));
      return;
    }
    final salon = await salonRepository.getSalonById(booking.salonId);
    SalonService? service;
    if (salon != null) {
      for (final item in salon.services) {
        if (item.id == booking.serviceId) {
          service = item;
          break;
        }
      }
    }
    if (salon == null || service == null) {
      emit(const BookingState(isLoading: false, errorMessage: 'That appointment cannot be rescheduled.'));
      return;
    }
    emit(
      BookingState(
        isLoading: false,
        step: BookingStep.schedule,
        rescheduleBookingId: booking.id,
        salon: salon,
        service: service,
        preferredStylistId: booking.stylistId,
        selectedDay: engine.firstOpenDay(salon.stylists, from: clock()),
      ),
    );
    await _reloadSlots(emit);
  }

  void _onStylistChosen(BookingStylistChosen event, Emitter<BookingState> emit) {
    emit(
      state.copyWith(
        preferredStylistId: event.stylistId,
        clearPreferredStylist: event.stylistId == null,
        clearSelectedSlot: true,
        clearConflict: true,
      ),
    );
  }

  Future<void> _onContinueToSchedule(BookingContinueToSchedule event, Emitter<BookingState> emit) async {
    emit(state.copyWith(step: BookingStep.schedule, clearSelectedSlot: true, clearConflict: true));
    await _reloadSlots(emit);
  }

  Future<void> _onDayChosen(BookingDayChosen event, Emitter<BookingState> emit) async {
    emit(
      state.copyWith(
        selectedDay: DateTimeUtils.startOfDay(event.day),
        clearSelectedSlot: true,
        clearConflict: true,
      ),
    );
    await _reloadSlots(emit);
  }

  void _onSlotChosen(BookingSlotChosen event, Emitter<BookingState> emit) {
    emit(state.copyWith(selectedSlot: event.slot, clearConflict: true));
  }

  void _onContinueToConfirm(BookingContinueToConfirm event, Emitter<BookingState> emit) {
    if (state.selectedSlot == null) return;
    emit(state.copyWith(step: BookingStep.confirm, clearConflict: true));
  }

  Future<void> _onSubmitted(BookingSubmitted event, Emitter<BookingState> emit) async {
    final salon = state.salon;
    final service = state.service;
    final slot = state.selectedSlot;
    if (salon == null || service == null || slot == null) return;

    emit(state.copyWith(isSubmitting: true, clearConflict: true, clearError: true));
    try {
      final booking = state.isRescheduling
          ? await bookingRepository.rescheduleBooking(
              bookingId: state.rescheduleBookingId!,
              newStart: slot.start,
              durationMinutes: service.durationMinutes,
              stylists: salon.stylists,
            )
          : await bookingRepository.createBooking(
              salonId: salon.id,
              serviceId: service.id,
              clientId: AppUser.guestClientId,
              start: slot.start,
              durationMinutes: service.durationMinutes,
              stylists: salon.stylists,
              preferredStylistId: state.preferredStylistId,
            );
      emit(
        state.copyWith(
          isSubmitting: false,
          step: BookingStep.success,
          confirmedBooking: booking,
        ),
      );
    } on BookingConflictException catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          step: BookingStep.schedule,
          conflictMessage: error.message,
          clearSelectedSlot: true,
        ),
      );
      await _reloadSlots(emit);
    } on Object catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
    }
  }

  void _onBack(BookingBack event, Emitter<BookingState> emit) {
    switch (state.step) {
      case BookingStep.schedule:
        emit(state.copyWith(step: BookingStep.stylist, clearConflict: true));
      case BookingStep.confirm:
        emit(state.copyWith(step: BookingStep.schedule));
      case BookingStep.stylist:
      case BookingStep.success:
        break;
    }
  }

  Future<void> _reloadSlots(Emitter<BookingState> emit) async {
    final salon = state.salon;
    final service = state.service;
    final day = state.selectedDay;
    if (salon == null || service == null || day == null) return;

    final bookings = await bookingRepository.getBookings();
    final activeBookings = state.rescheduleBookingId == null
        ? bookings
        : bookings.where((booking) => booking.id != state.rescheduleBookingId).toList(growable: false);
    final now = clock();
    final slots = state.preferredStylistId == null
        ? engine.slotsForAnyStylist(
            stylists: salon.stylists,
            durationMinutes: service.durationMinutes,
            day: day,
            bookings: activeBookings,
            now: now,
          )
        : engine.slotsForStylist(
            stylist: salon.stylists.firstWhere((stylist) => stylist.id == state.preferredStylistId),
            durationMinutes: service.durationMinutes,
            day: day,
            bookings: activeBookings,
            now: now,
          );
    emit(state.copyWith(slots: slots));
  }
}
