import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/voice_cloning/vocal_fatigue_guard.dart';

void main() {
  test('N011: VocalFatigueGuard monitors vocal health', () {
    final guard = VocalFatigueGuard();
    expect(guard.isRestRequired(jitterPercent: 3.0, shimmerPercent: 2.0), isTrue);
    expect(guard.isRestRequired(jitterPercent: 1.0, shimmerPercent: 2.0), isFalse);
  });
}
