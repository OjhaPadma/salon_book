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

  Booking copyWith({
    String? id,
    String? salonId,
    String? serviceId,
    String? stylistId,
    String? clientId,
    DateTime? start,
    DateTime? end,
    BookingStatus? status,
    String? notes,
  }) {
    return Booking(
      id: id ?? this.id,
      salonId: salonId ?? this.salonId,
      serviceId: serviceId ?? this.serviceId,
      stylistId: stylistId ?? this.stylistId,
      clientId: clientId ?? this.clientId,
      start: start ?? this.start,
      end: end ?? this.end,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

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
