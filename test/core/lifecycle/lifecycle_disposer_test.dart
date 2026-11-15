import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/core/lifecycle/lifecycle_disposer.dart';

void main() {
  group('LifecycleDisposer Memory Leak Prevention Tests', () {
    test('Cancels all active stream subscriptions and timers upon dispose', () async {
      final disposer = LifecycleDisposer();

      final controller = StreamController<int>.broadcast();
      var eventCount = 0;

      // Bind subscription
      disposer.bindSubscription(controller.stream.listen((val) {
        eventCount += val;
      }));

      // Bind timer
      disposer.bindTimer(Timer.periodic(const Duration(milliseconds: 10), (_) {
        eventCount++;
      }));

      expect(disposer.activeSubscriptionCount, equals(1));
      expect(disposer.activeTimerCount, equals(1));

      // Emit event before dispose
      controller.add(5);
      await Future.delayed(const Duration(milliseconds: 15));
      expect(eventCount, greaterThanOrEqualTo(5));

      final countAtDispose = eventCount;

      // Trigger navigation dispose
      disposer.dispose();
      expect(disposer.isDisposed, isTrue);

      // Emit event after dispose
      controller.add(10);
      await Future.delayed(const Duration(milliseconds: 25));

      // Assert zero events processed post-dispose (leak prevented)
      expect(eventCount, equals(countAtDispose));
      await controller.close();
    });

    test('Disposal is completely idempotent and safe against repeated calls', () {
      final disposer = LifecycleDisposer();
      var teardownCalls = 0;

      disposer.addTeardown(() {
        teardownCalls++;
      });

      disposer.dispose();
      disposer.dispose(); // Duplicate call
      disposer.dispose(); // Triplicate call

      expect(teardownCalls, equals(1));
      expect(disposer.isDisposed, isTrue);
    });
  });
}
