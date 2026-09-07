import 'package:flutter_test/flutter_test.dart';
import 'package:salon_book/core/utils/date_time_utils.dart';

void main() {
  test('formatMinutes renders hours and leftover minutes', () {
    expect(DateTimeUtils.formatMinutes(45), '45m');
    expect(DateTimeUtils.formatMinutes(60), '1h');
    expect(DateTimeUtils.formatMinutes(90), '1h 30m');
  });

  test('overlaps detects colliding ranges', () {
    final start = DateTime(2026, 9, 7, 10);
    final end = DateTime(2026, 9, 7, 11);

    expect(
      DateTimeUtils.overlaps(
        startA: start,
        endA: end,
        startB: DateTime(2026, 9, 7, 10, 30),
        endB: DateTime(2026, 9, 7, 11, 30),
      ),
      isTrue,
    );
    expect(
      DateTimeUtils.overlaps(
        startA: start,
        endA: end,
        startB: end,
        endB: DateTime(2026, 9, 7, 12),
      ),
      isFalse,
    );
  });
}
