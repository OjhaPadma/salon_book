import 'package:equatable/equatable.dart';

class TimeWindow extends Equatable {
  const TimeWindow({required this.startMinutes, required this.endMinutes});

  /// Minutes from midnight, inclusive.
  final int startMinutes;

  /// Minutes from midnight, exclusive.
  final int endMinutes;

  @override
  List<Object?> get props => [startMinutes, endMinutes];
}

class WorkingHours extends Equatable {
  const WorkingHours(this.days);

  /// Keys are [DateTime.monday] (1) through [DateTime.sunday] (7).
  final Map<int, TimeWindow> days;

  TimeWindow? forWeekday(int weekday) => days[weekday];

  @override
  List<Object?> get props => [days];
}
