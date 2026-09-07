import 'package:intl/intl.dart';

abstract final class DateTimeUtils {
  static final DateFormat _dayMonth = DateFormat('EEE, d MMM');
  static final DateFormat _full = DateFormat('EEE, d MMM yyyy');
  static final DateFormat _time = DateFormat('h:mm a');

  static String formatDay(DateTime date) => _dayMonth.format(date);

  static String formatFullDate(DateTime date) => _full.format(date);

  static String formatTime(DateTime date) => _time.format(date);

  static String formatTimeRange(DateTime start, DateTime end) =>
      '${formatTime(start)} – ${formatTime(end)}';

  static String formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    if (rest == 0) return '${hours}h';
    return '${hours}h ${rest}m';
  }

  static DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

  static DateTime addMinutes(DateTime date, int minutes) =>
      date.add(Duration(minutes: minutes));

  /// Buffer after a service before the next booking may start.
  static DateTime withBuffer(DateTime end, {int bufferMinutes = 15}) =>
      addMinutes(end, bufferMinutes);

  static bool overlaps({
    required DateTime startA,
    required DateTime endA,
    required DateTime startB,
    required DateTime endB,
  }) {
    return startA.isBefore(endB) && startB.isBefore(endA);
  }
}
