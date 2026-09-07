import 'package:equatable/equatable.dart';
import 'package:salon_book/domain/models/time_slot.dart';

sealed class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class BookingStarted extends BookingEvent {
  const BookingStarted({required this.salonId, required this.serviceId});

  final String salonId;
  final String? serviceId;

  @override
  List<Object?> get props => [salonId, serviceId];
}

class BookingStylistChosen extends BookingEvent {
  const BookingStylistChosen(this.stylistId);

  final String? stylistId;

  @override
  List<Object?> get props => [stylistId];
}

class BookingContinueToSchedule extends BookingEvent {
  const BookingContinueToSchedule();
}

class BookingDayChosen extends BookingEvent {
  const BookingDayChosen(this.day);

  final DateTime day;

  @override
  List<Object?> get props => [day];
}

class BookingSlotChosen extends BookingEvent {
  const BookingSlotChosen(this.slot);

  final TimeSlot slot;

  @override
  List<Object?> get props => [slot];
}

class BookingContinueToConfirm extends BookingEvent {
  const BookingContinueToConfirm();
}

class BookingSubmitted extends BookingEvent {
  const BookingSubmitted();
}

class BookingBack extends BookingEvent {
  const BookingBack();
}
