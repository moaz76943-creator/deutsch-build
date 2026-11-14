import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/voice_cloning/continuous_tts_stress_guard.dart';

void main() {
  group('ContinuousTtsStressGuard Unit Tests (N019)', () {
    test('Acquire and release cycles effectively reuse memory pool', () {
      final guard = ContinuousTtsStressGuard(maxPooledBuffers: 8);
      final buf1 = guard.acquireBuffer(1024);
      guard.releaseBuffer(buf1);

      expect(guard.activePoolSize, equals(1));
      final buf2 = guard.acquireBuffer(1024);
      expect(guard.recycledCount, equals(1));
      expect(guard.activePoolSize, equals(0));
      guard.releaseBuffer(buf2);
    });

    test('Stress cycle verifies zero-leak guarantee during 500 audio frames', () {
      final guard = ContinuousTtsStressGuard(maxPooledBuffers: 16);
      final metrics = guard.runStressCycle(iterations: 500, bufferSize: 2048);

      expect(metrics['isLeakFree'], isTrue);
      expect(metrics['netLeakBytes'], equals(0));
      expect(metrics['totalRecycled'], greaterThan(400));
    });

    test('Exceeding max buffer size throws ArgumentError', () {
      final guard = ContinuousTtsStressGuard(maxBufferSizeBytes: 1000);
      expect(() => guard.acquireBuffer(2000), throwsArgumentError);
    });

    test('Purge resets internal metrics completely', () {
      final guard = ContinuousTtsStressGuard();
      guard.acquireBuffer(512);
      guard.purge();
      expect(guard.activePoolSize, equals(0));
      expect(guard.allocatedBytes, equals(0));
      expect(guard.recycledCount, equals(0));
    });
  });
}
