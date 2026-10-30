import 'package:test/test.dart';
import '../../lib/src/core/voice_cloning/choral_shadowing_sync.dart';

void main() {
  test('N014: ChoralShadowingSync aligns audio streams', () {
    final sync = ChoralShadowingSync();
    expect(sync.calculateAlignmentDelay(1.25, 1.0), closeTo(0.25, 0.001));
  });
}
