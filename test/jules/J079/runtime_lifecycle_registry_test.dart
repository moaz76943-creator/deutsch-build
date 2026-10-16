import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/lifecycle/runtime_lifecycle_registry.dart';

void main() {
  late RuntimeLifecycleRegistry registry;

  setUp(() {
    registry = RuntimeLifecycleRegistry.instance;
    registry.reset();
  });

  tearDown(() {
    registry.reset();
  });

  test('Registered resources are cleaned up deterministically', () async {
    bool timerCancelled = false;
    bool subCancelled = false;
    bool callbackRun = false;

    final timer = Timer(const Duration(hours: 1), () {});
    final streamController = StreamController<int>(onCancel: () {
      subCancelled = true;
    });
    final sub = streamController.stream.listen((_) {});

    registry.registerTimer(timer, ownerKey: 'feature_a');
    registry.registerSubscription(sub, ownerKey: 'feature_a');
    registry.registerCleanupCallback(() {
      callbackRun = true;
      timerCancelled = !timer.isActive; // check if timer was cancelled before callback
    }, ownerKey: 'feature_a');

    await registry.disposeOwner('feature_a');

    expect(timer.isActive, isFalse, reason: 'Timer should be cancelled');
    expect(subCancelled, isTrue, reason: 'Subscription should be cancelled');
    expect(callbackRun, isTrue, reason: 'Callback should be run');
    expect(timerCancelled, isTrue, reason: 'Timer should be cancelled before callback runs');
  });

  test('Duplicate disposal is safe', () async {
    int cleanupCount = 0;
    registry.registerCleanupCallback(() {
      cleanupCount++;
    }, ownerKey: 'feature_b');

    await registry.disposeOwner('feature_b');
    await registry.disposeOwner('feature_b'); // duplicate
    await registry.disposeAll(); // global duplicate

    expect(cleanupCount, equals(1), reason: 'Cleanup should only run once');
  });

  test('Stale callbacks cannot mutate disposed feature state', () async {
    await registry.disposeOwner('feature_c');

    bool subCancelledImm = false;
    final streamController = StreamController<int>(onCancel: () {
      subCancelledImm = true;
    });
    final sub = streamController.stream.listen((_) {});

    bool callbackRunImm = false;

    // Register after dispose
    registry.registerSubscription(sub, ownerKey: 'feature_c');
    registry.registerCleanupCallback(() {
      callbackRunImm = true;
    }, ownerKey: 'feature_c');

    expect(subCancelledImm, isTrue, reason: 'Sub should be cancelled immediately on stale registration');
    expect(callbackRunImm, isTrue, reason: 'Callback should be run immediately on stale registration');
  });

  test('Cleanup errors are isolated and observable locally', () async {
    int successCount = 0;

    registry.registerCleanupCallback(() {
      throw Exception('Failing cleanup');
    });

    registry.registerCleanupCallback(() {
      successCount++;
    });

    await expectLater(registry.disposeAll(), completes);
    expect(successCount, equals(1), reason: 'Subsequent cleanups should run even if one throws');
  });

  test('Bounded cleanup timeouts prevent hangs', () async {
    bool nextRun = false;
    registry.registerCleanupCallback(() async {
      await Future.delayed(const Duration(seconds: 10));
    });

    registry.registerCleanupCallback(() {
      nextRun = true;
    });

    // Time it, should be roughly 5 seconds (the timeout limit) rather than 10
    final stopwatch = Stopwatch()..start();
    await registry.disposeAll();
    stopwatch.stop();

    expect(stopwatch.elapsedMilliseconds >= 4900, isTrue);
    expect(stopwatch.elapsedMilliseconds < 8000, isTrue, reason: 'Should timeout after 5 seconds and not wait 10');
    expect(nextRun, isTrue, reason: 'Next cleanup should still execute');
  });
}
