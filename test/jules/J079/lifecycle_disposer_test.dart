import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/lifecycle/lifecycle_disposer.dart';

void main() {
  group('LifecycleDisposer tests', () {
    test('Repeated disposal is safe and idempotent', () {
      final disposer = LifecycleDisposer();
      int callCount = 0;
      disposer.addTeardown(() => callCount++);

      disposer.dispose();
      disposer.dispose();
      expect(callCount, 1);
      expect(disposer.isDisposed, true);
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

    test('Failed cleanup does not skip independent remaining cleanup operations', () {
      final disposer = LifecycleDisposer();
      int callCount = 0;

      disposer.addTeardown(() => callCount++);
      disposer.addTeardown(() => throw Exception('Intentional failure'));
      disposer.addTeardown(() => callCount++);

      disposer.dispose();
      expect(callCount, 2);
    });

    test('Stream subscription is cancelled safely', () {
      final disposer = LifecycleDisposer();
      final controller = StreamController<int>();
      bool isCancelled = false;

      controller.onCancel = () {
        isCancelled = true;
      };

      final sub = controller.stream.listen((_) {});
      disposer.bindSubscription(sub);

      disposer.dispose();
      expect(isCancelled, true);
    });

    test('Timer is cancelled safely', () {
      final disposer = LifecycleDisposer();
      bool timerFired = false;
      final timer = Timer(const Duration(milliseconds: 100), () {
        timerFired = true;
      });
      disposer.bindTimer(timer);

      disposer.dispose();
      expect(timerFired, false);
      expect(timer.isActive, false);
    });

    test('guard() prevents stale synchronous callbacks', () {
      final disposer = LifecycleDisposer();
      int execCount = 0;

      void callback() {
        disposer.guard(() {
          execCount++;
        });
      }

      callback();
      expect(execCount, 1);

      disposer.dispose();
      callback();
      expect(execCount, 1);
    });

    test('guardFuture() prevents stale asynchronous callbacks', () async {
      final disposer = LifecycleDisposer();
      final completer = Completer<int>();

      final futureResult = disposer.guardFuture(completer.future);

      disposer.dispose();
      completer.complete(42);

      final result = await futureResult;
      expect(result, isNull);
    });

    test('Registering resources after disposal cleans them up immediately', () {
      final disposer = LifecycleDisposer();
      disposer.dispose();

      // Teardown
      int teardownExecs = 0;
      disposer.addTeardown(() => teardownExecs++);
      expect(teardownExecs, 1);

      // Subscription
      final controller = StreamController<int>();
      bool subCancelled = false;
      controller.onCancel = () {
        subCancelled = true;
      };
      final sub = controller.stream.listen((_) {});
      disposer.bindSubscription(sub);
      expect(subCancelled, true);

      // Timer
      final timer = Timer(const Duration(milliseconds: 100), () {});
      disposer.bindTimer(timer);
      expect(timer.isActive, false);
    });
  });
}
