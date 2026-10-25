import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/lifecycle/runtime_lifecycle_registry.dart';

void main() {
  late RuntimeLifecycleRegistry registry;

  setUp(() {
    registry = RuntimeLifecycleRegistry.instance;
    registry.resetForTest();
  });

  tearDown(() {
    registry.resetForTest();
  });

  group('RuntimeLifecycleRegistry Lifecycle Management', () {
    test('Registered resources are cleaned up deterministically in reverse order (LIFO)', () async {
      final executionOrder = <int>[];

      registry.registerCleanup(() => executionOrder.add(1), owner: 'featureA');
      registry.registerCleanup(() => executionOrder.add(2), owner: 'featureA');
      registry.registerCleanup(() => executionOrder.add(3), owner: 'featureA');

      await registry.disposeOwner('featureA');

      expect(executionOrder, [3, 2, 1]);
    });

    test('Duplicate dispose calls on the same owner are safe and idempotent', () async {
      int cleanupInvocationCount = 0;

      registry.registerCleanup(() {
        cleanupInvocationCount++;
      }, owner: 'featureB');

      await registry.disposeOwner('featureB');
      await registry.disposeOwner('featureB');
      await registry.disposeAll();

      expect(cleanupInvocationCount, 1);
    });

    test('Cleanup errors in one resource do not skip the remaining independent operations', () async {
      int successfulCleanups = 0;

      registry.registerCleanup(() {
        successfulCleanups++;
      }, owner: 'featureC');

      registry.registerCleanup(() {
        throw Exception('Simulated cleanup failure');
      }, owner: 'featureC');

      registry.registerCleanup(() {
        successfulCleanups++;
      }, owner: 'featureC');

      await registry.disposeOwner('featureC');

      expect(successfulCleanups, 2);
    });

    test('Abandoned subscriptions and timers are cleaned up on disposal', () async {
      bool timerCancelled = false;

      final timer = Timer(const Duration(seconds: 10), () {
        timerCancelled = true;
      });
      final sub = Stream.periodic(const Duration(seconds: 1)).listen((_) {});

      registry.registerTimer(timer, owner: 'featureD');
      registry.registerSubscription(sub, owner: 'featureD');

      await registry.disposeOwner('featureD');

      expect(timer.isActive, false);
    });

    test('guard and guardFuture correctly prevent stale callbacks from modifying state after disposal', () async {
      bool syncCallbackExecuted = false;

      await registry.disposeOwner('featureE');

      registry.guard(() {
        syncCallbackExecuted = true;
      }, owner: 'featureE');

      expect(syncCallbackExecuted, false);

      bool futureExecuted = false;
      final result = await registry.guardFuture(Future.value(() {
        futureExecuted = true;
        return true;
      }()), owner: 'featureE');

      expect(result, null);
      expect(futureExecuted, true);
    });

    test('Resources registered after disposal are immediately cleaned up', () async {
      int postDisposalCleanupCount = 0;

      await registry.disposeOwner('featureF');

      registry.registerCleanup(() {
        postDisposalCleanupCount++;
      }, owner: 'featureF');

      await Future.delayed(const Duration(milliseconds: 50));

      expect(postDisposalCleanupCount, 1);
    });

    test('Race condition is handled when clearing cleanups before execution', () async {
      int executionCount = 0;

      registry.registerCleanup(() async {
        executionCount++;
        // Simulate a new registration while cleanup is ongoing
        registry.registerCleanup(() {
          executionCount++;
        }, owner: 'featureG');
      }, owner: 'featureG');

      await registry.disposeOwner('featureG');
      await Future.delayed(const Duration(milliseconds: 50));

      // The secondary cleanup immediately fires because the owner is marked disposed
      expect(executionCount, 2);
    });

    test('Long-running cleanups enforce a bounded cleanup timeout', () async {
      int completedCleanups = 0;
      registry.registerCleanup(() async {
        await Future.delayed(const Duration(seconds: 6));
        completedCleanups++;
      }, owner: 'featureH');

      final start = DateTime.now();
      await registry.disposeOwner('featureH');
      final elapsed = DateTime.now().difference(start);

      // The disposal should return after ~5 seconds because of the bounded timeout.
      expect(elapsed.inSeconds, inInclusiveRange(4, 6));
      expect(completedCleanups, 0); // Didn't finish before the method returned
    });
  });
}
