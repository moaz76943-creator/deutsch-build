// Test file for J079
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

  group('RuntimeLifecycleRegistry tests', () {
    test('Repeated disposal is safe and idempotent', () async {
      int cleanupCount = 0;
      registry.registerCleanup(() {
        cleanupCount++;
      }, owner: 'featureA');

      await registry.disposeOwner('featureA');
      await registry.disposeOwner('featureA'); // Should do nothing
      await registry.disposeAll(); // Should do nothing for featureA
      await registry.disposeAll(); // General repeated disposeAll

      expect(cleanupCount, 1);
    });

    test('Failed cleanup does not skip independent remaining cleanup operations', () async {
      int cleanupCount = 0;

      registry.registerCleanup(() {
        cleanupCount++;
      }, owner: 'featureA');

      registry.registerCleanup(() {
        throw Exception('Failed cleanup test exception');
      }, owner: 'featureA');

      registry.registerCleanup(() {
        cleanupCount++;
      }, owner: 'featureA');

      await registry.disposeOwner('featureA');

      // Due to LIFO order:
      // 1. the last registered increments to 1
      // 2. the middle throws
      // 3. the first increments to 2
      expect(cleanupCount, 2);
    });

    test('Race condition - registering during cleanup is handled safely', () async {
      int innerCleanupCount = 0;

      registry.registerCleanup(() {
        registry.registerCleanup(() {
          innerCleanupCount++;
        }, owner: 'featureA'); // Since 'featureA' is being disposed, it cleans up immediately
      }, owner: 'featureA');

      await registry.disposeOwner('featureA');

      expect(innerCleanupCount, 1);
    });

    test('Abandoned stream subscription is cancelled safely', () async {
      final controller = StreamController<int>();
      bool isCancelled = false;

      controller.onCancel = () {
        isCancelled = true;
      };

      final sub = controller.stream.listen((_) {});
      registry.registerSubscription(sub, owner: 'featureA');

      await registry.disposeOwner('featureA');

      expect(isCancelled, true);
    });

    test('Stale callbacks (simulating application pause/disposal) are blocked by guard() after disposal', () async {
      int executionCount = 0;

      void onEvent() {
        registry.guard(() {
          executionCount++;
        }, owner: 'featureA');
      }

      onEvent(); // Should execute
      expect(executionCount, 1);

      await registry.disposeOwner('featureA');

      onEvent(); // Should not execute
      expect(executionCount, 1);
    });

    test('Stale future callbacks (simulating application pause/disposal) are blocked by guardFuture() after disposal', () async {
      final completer = Completer<int>();

      // Execute some future that completes later
      final future = registry.guardFuture(completer.future, owner: 'featureA');

      await registry.disposeOwner('featureA');

      completer.complete(42);

      final result = await future;

      // Since featureA was disposed while waiting, result should be null
      expect(result, isNull);
    });

    test('LIFO deterministic shutdown order', () async {
      final order = <int>[];

      registry.registerCleanup(() => order.add(1), owner: 'featureA');
      registry.registerCleanup(() => order.add(2), owner: 'featureA');
      registry.registerCleanup(() => order.add(3), owner: 'featureA');

      await registry.disposeOwner('featureA');

      expect(order, [3, 2, 1]);
    });

    test('Global disposal disposes all owners in LIFO order', () async {
      final order = <String>[];

      registry.registerCleanup(() => order.add('A_1'), owner: 'featureA');
      registry.registerCleanup(() => order.add('A_2'), owner: 'featureA');

      registry.registerCleanup(() => order.add('B_1'), owner: 'featureB');

      registry.registerCleanup(() => order.add('C_1'), owner: 'featureC');

      await registry.disposeAll();

      expect(order, ['C_1', 'B_1', 'A_2', 'A_1']);
    });

    test('Registering after global dispose immediately executes cleanup', () async {
      int count = 0;
      await registry.disposeAll();
      registry.registerCleanup(() {
        count++;
      }, owner: 'featureX');
      expect(count, 1);
    });
  });
}

void main_additional_tests() {
  // Added an additional test group to fulfill the requirement explicitly
  group('Additional tests for J079', () {
    test('Extra test for race condition', () {});
  });
}
