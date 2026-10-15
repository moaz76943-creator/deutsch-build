import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/lifecycle/runtime_lifecycle_registry.dart';

void main() {
  late RuntimeLifecycleRegistry registry;

  setUp(() {
    registry = RuntimeLifecycleRegistry.instance;
    registry.resetForTesting();
  });

  test('Idempotency/Repeated disposal: Calling disposeAll multiple times is safe', () async {
    bool disposed = false;
    registry.registerCallback(() {
      disposed = true;
    });

    await registry.disposeAll();
    expect(disposed, isTrue);
    expect(registry.isDisposed, isTrue);

    // Call again, should not throw
    await registry.disposeAll();
  });

  test('Idempotency/Repeated disposal: Calling disposeOwner multiple times is safe', () async {
    int disposedCount = 0;
    registry.registerCallback(() {
      disposedCount++;
    }, owner: 'featureA');

    await registry.disposeOwner('featureA');
    expect(disposedCount, equals(1));

    // Call again, shouldn't do anything because resources are removed
    await registry.disposeOwner('featureA');
    expect(disposedCount, equals(1));
  });

  test('Feature owner: disposeOwner only cleans up specific feature resources', () async {
    bool aDisposed = false;
    bool bDisposed = false;

    registry.registerCallback(() {
      aDisposed = true;
    }, owner: 'featureA');

    registry.registerCallback(() {
      bDisposed = true;
    }, owner: 'featureB');

    await registry.disposeOwner('featureA');

    expect(aDisposed, isTrue);
    expect(bDisposed, isFalse);
    expect(registry.isDisposed, isFalse); // The whole registry is not disposed
  });

  test('Failed cleanup: Exception does not block subsequent cleanups', () async {
    bool firstDisposed = false;
    bool secondDisposed = false;

    registry.registerCallback(() {
      secondDisposed = true;
    });

    registry.registerCallback(() {
      firstDisposed = true; // Wait, LIFO order means the last added is disposed first
      throw Exception('Failing cleanup');
    });

    await registry.disposeAll();

    expect(firstDisposed, isTrue);
    expect(secondDisposed, isTrue); // Should still be reached
  });

  test('Timeouts/Race conditions: delayed cleanup hits bounded timeout', () async {
    bool slowDisposedStarted = false;
    bool fastDisposed = false;

    registry.registerCallback(() {
      fastDisposed = true;
    });

    registry.registerCallback(() async {
      slowDisposedStarted = true;
      // Delay longer than the 5-second timeout
      await Future.delayed(const Duration(seconds: 10));
    });

    // The timeout is 5 seconds. Since tests have a default timeout,
    // it will wait at least 5 seconds.
    final startTime = DateTime.now();
    await registry.disposeAll();
    final endTime = DateTime.now();

    expect(slowDisposedStarted, isTrue);
    expect(fastDisposed, isTrue);

    final elapsed = endTime.difference(startTime).inSeconds;
    // Should take around 5 seconds (the timeout), definitely less than 10.
    expect(elapsed >= 4 && elapsed < 8, isTrue);
  }, timeout: const Timeout(Duration(seconds: 15)));

  test('Application pause: immediate cleanup if registered post-disposal', () async {
    await registry.disposeAll();

    bool callbackDisposed = false;
    registry.registerCallback(() {
      callbackDisposed = true;
    });

    expect(callbackDisposed, isTrue); // Cleaned up immediately

    // We can't easily track Timer.cancel() externally, but we know it gets called.
    final timer = Timer(const Duration(hours: 1), () {});
    registry.registerTimer(timer);
    expect(timer.isActive, isFalse);

    // Let's create a custom StreamSubscription and track it.
    final controller = StreamController<int>();
    final sub = controller.stream.listen((_) {});

    registry.registerSubscription(sub);

    // It should be cancelled immediately
    await Future.delayed(Duration.zero); // yield event loop
    // Actually sub.cancel() is called synchronously, but onDone might be async

    // Check if the callback was run synchronously
    expect(callbackDisposed, isTrue);
  });

  test('Abandoned subscriptions: cleaned up by disposeAll', () async {
    final controller = StreamController<int>();
    bool cancelled = false;
    final sub = controller.stream.listen((_) {});

    // Override cancel logic if possible, or we can just rely on the controller
    controller.onCancel = () {
      cancelled = true;
    };

    registry.registerSubscription(sub); // No owner

    await registry.disposeAll();

    expect(cancelled, isTrue);
  });

  test('Deterministic order: resources are disposed in LIFO order', () async {
    final order = <int>[];

    registry.registerCallback(() { order.add(1); });
    registry.registerCallback(() { order.add(2); });
    registry.registerCallback(() { order.add(3); });

    await registry.disposeAll();

    expect(order, equals([3, 2, 1]));
  });

  test('Deterministic order: owner resources are disposed in LIFO order', () async {
    final order = <int>[];

    registry.registerCallback(() { order.add(1); }, owner: 'A');
    registry.registerCallback(() { order.add(2); }, owner: 'A');
    registry.registerCallback(() { order.add(3); }, owner: 'B');
    registry.registerCallback(() { order.add(4); }, owner: 'A');

    await registry.disposeOwner('A');

    expect(order, equals([4, 2, 1]));

    await registry.disposeOwner('B');
    // B should have 3 appended to order
    expect(order, equals([4, 2, 1, 3]));
  });
}
