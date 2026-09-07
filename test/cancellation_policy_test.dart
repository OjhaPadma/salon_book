import 'package:flutter_test/flutter_test.dart';
import 'package:salon_book/features/appointments/domain/cancellation_policy.dart';

void main() {
  final start = DateTime(2026, 9, 10, 14);

  test('allows free cancellation more than 24 hours ahead', () {
    final now = DateTime(2026, 9, 9, 10);
    expect(CancellationPolicy.canCancelFree(now: now, start: start), isTrue);
    expect(CancellationPolicy.message(now: now, start: start), contains('Free cancellation'));
  });

  test('warns inside the 24 hour window', () {
    final now = DateTime(2026, 9, 10, 8);
    expect(CancellationPolicy.canCancelFree(now: now, start: start), isFalse);
    expect(CancellationPolicy.message(now: now, start: start), contains('Within 24 hours'));
  });
}
