import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/lifecycle/lifecycle_disposer.dart';

void main() {
  group('LifecycleDisposer tests', () {
    test('Repeated disposal is safe and idempotent', () {
      final disposer = LifecycleDisposer();
      int count = 0;
      disposer.addTeardown(() => count++);

      disposer.dispose();
      disposer.dispose(); // Should do nothing

      expect(count, 1);
    });

    test('Failed cleanup does not skip independent remaining operations', () {
      final disposer = LifecycleDisposer();
      int count = 0;

      disposer.addTeardown(() => count++);
      disposer.addTeardown(() => throw Exception('error'));
      disposer.addTeardown(() => count++);

      disposer.dispose();
      // Because of LIFO, it runs the last added first (count++), then throws, then runs the first added (count++)
      expect(count, 2);
    });

    test('LIFO deterministic shutdown order', () {
      final disposer = LifecycleDisposer();
      final order = <int>[];

      disposer.addTeardown(() => order.add(1));
      disposer.addTeardown(() => order.add(2));
      disposer.addTeardown(() => order.add(3));

      disposer.dispose();

      expect(order, [3, 2, 1]);
    });

    test('Abandoned streams and timers are cancelled safely', () {
      final disposer = LifecycleDisposer();
      final controller = StreamController<int>();
      bool isCancelled = false;

      controller.onCancel = () {
        isCancelled = true;
      };

      disposer.bindSubscription(controller.stream.listen((_) {}));

      int timerTicks = 0;
      disposer.bindTimer(Timer.periodic(const Duration(milliseconds: 10), (t) {
        timerTicks++;
      }));

      disposer.dispose();

      expect(isCancelled, true);
      expect(disposer.activeSubscriptionCount, 0);
      expect(disposer.activeTimerCount, 0);
    });
  });

  group('LifecycleDisposer additional edge cases', () {
    test('Application pause (simulated) does not execute stale teardowns', () {
      final disposer = LifecycleDisposer();
      int executionCount = 0;

      void executeAction() {
        if (disposer.isDisposed) return;
        executionCount++;
      }

      executeAction();
      expect(executionCount, 1);

      disposer.dispose();

      executeAction();
      expect(executionCount, 1); // Should not execute after dispose
    });

    test('Race condition - bind during dispose returns cancelled subscription/timer', () {
      final disposer = LifecycleDisposer();
      disposer.dispose();

      final controller = StreamController<int>();
      bool isCancelled = false;
      controller.onCancel = () { isCancelled = true; };

      disposer.bindSubscription(controller.stream.listen((_) {}));

      expect(isCancelled, true);

      int timerTicks = 0;
      final timer = disposer.bindTimer(Timer.periodic(const Duration(milliseconds: 10), (t) {
        timerTicks++;
      }));

      expect(timer.isActive, false);
      expect(disposer.activeSubscriptionCount, 0);
      expect(disposer.activeTimerCount, 0);
    });
  });
}
