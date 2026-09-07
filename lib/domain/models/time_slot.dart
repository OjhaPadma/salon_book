import 'package:equatable/equatable.dart';

class TimeSlot extends Equatable {
  const TimeSlot({
    required this.id,
    required this.stylistId,
    required this.start,
    required this.end,
    this.isAvailable = true,
  });

  final String id;
  final String stylistId;
  final DateTime start;
  final DateTime end;
  final bool isAvailable;

  @override
  List<Object?> get props => [id, stylistId, start, end, isAvailable];
}
