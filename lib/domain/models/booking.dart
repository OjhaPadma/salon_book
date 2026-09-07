import 'package:equatable/equatable.dart';

import 'booking_status.dart';

class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.salonId,
    required this.serviceId,
    required this.stylistId,
    required this.clientId,
    required this.start,
    required this.end,
    required this.status,
    this.notes,
  });

  final String id;
  final String salonId;
  final String serviceId;
  final String stylistId;
  final String clientId;
  final DateTime start;
  final DateTime end;
  final BookingStatus status;
  final String? notes;

  @override
  List<Object?> get props => [
    id,
    salonId,
    serviceId,
    stylistId,
    clientId,
    start,
    end,
    status,
    notes,
  ];
}
