import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/voice_cloning/breath_micro_pause_naturalizer.dart';

void main() {
  test('N006: BreathNaturalizer injects pause', () {
    final nat = BreathMicroPauseNaturalizer();
    final res = nat.injectBreathPause([0.1, 0.2], 5);
    expect(res.length, equals(7));
  });
}
