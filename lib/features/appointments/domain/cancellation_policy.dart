abstract final class CancellationPolicy {
  static const Duration freeWindow = Duration(hours: 24);

  static bool canCancelFree({required DateTime now, required DateTime start}) {
    return start.difference(now) >= freeWindow;
  }

  static String message({required DateTime now, required DateTime start}) {
    if (canCancelFree(now: now, start: start)) {
      return 'Free cancellation — more than 24 hours before your appointment.';
    }
    return 'Within 24 hours of your appointment, cancellations may incur a fee at the salon’s discretion.';
  }
}
