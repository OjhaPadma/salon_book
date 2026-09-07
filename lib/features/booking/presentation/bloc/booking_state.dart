import 'package:equatable/equatable.dart';
import 'package:salon_book/domain/models/models.dart';

enum BookingStep { stylist, schedule, confirm, success }

class BookingState extends Equatable {
  const BookingState({
    this.step = BookingStep.stylist,
    this.isLoading = true,
    this.isSubmitting = false,
    this.salon,
    this.service,
    this.preferredStylistId,
    this.selectedDay,
    this.slots = const [],
    this.selectedSlot,
    this.confirmedBooking,
    this.errorMessage,
    this.conflictMessage,
    this.rescheduleBookingId,
  });

  final BookingStep step;
  final bool isLoading;
  final bool isSubmitting;
  final Salon? salon;
  final SalonService? service;
  final String? preferredStylistId;
  final DateTime? selectedDay;
  final List<TimeSlot> slots;
  final TimeSlot? selectedSlot;
  final Booking? confirmedBooking;
  final String? errorMessage;
  final String? conflictMessage;
  final String? rescheduleBookingId;

  bool get isRescheduling => rescheduleBookingId != null;

  Stylist? get selectedStylist {
    final id = selectedSlot?.stylistId ?? preferredStylistId;
    if (id == null) return null;
    for (final stylist in salon?.stylists ?? const <Stylist>[]) {
      if (stylist.id == id) return stylist;
    }
    return null;
  }

  String get stylistLabel {
    if (preferredStylistId == null && selectedSlot == null) return 'Any available';
    return selectedStylist?.name ?? 'Any available';
  }

  BookingState copyWith({
    BookingStep? step,
    bool? isLoading,
    bool? isSubmitting,
    Salon? salon,
    SalonService? service,
    String? preferredStylistId,
    DateTime? selectedDay,
    List<TimeSlot>? slots,
    TimeSlot? selectedSlot,
    Booking? confirmedBooking,
    String? errorMessage,
    String? conflictMessage,
    String? rescheduleBookingId,
    bool clearPreferredStylist = false,
    bool clearSelectedSlot = false,
    bool clearConflict = false,
    bool clearError = false,
  }) {
    return BookingState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      salon: salon ?? this.salon,
      service: service ?? this.service,
      preferredStylistId: clearPreferredStylist ? null : preferredStylistId ?? this.preferredStylistId,
      selectedDay: selectedDay ?? this.selectedDay,
      slots: slots ?? this.slots,
      selectedSlot: clearSelectedSlot ? null : selectedSlot ?? this.selectedSlot,
      confirmedBooking: confirmedBooking ?? this.confirmedBooking,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      conflictMessage: clearConflict ? null : conflictMessage ?? this.conflictMessage,
      rescheduleBookingId: rescheduleBookingId ?? this.rescheduleBookingId,
    );
  }

  @override
  List<Object?> get props => [
    step,
    isLoading,
    isSubmitting,
    salon,
    service,
    preferredStylistId,
    selectedDay,
    slots,
    selectedSlot,
    confirmedBooking,
    errorMessage,
    conflictMessage,
    rescheduleBookingId,
  ];
}
