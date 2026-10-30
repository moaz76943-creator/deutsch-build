import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/lifecycle/runtime_lifecycle_registry.dart';

void main() {
  group('RuntimeLifecycleRegistry - J079', () {
    late RuntimeLifecycleRegistry registry;

    setUp(() {
      registry = RuntimeLifecycleRegistry.instance;
      registry.resetForTesting();
    });

    test('deterministic shutdown (LIFO order)', () async {
      final List<int> disposedOrder = [];

      registry.registerResource(() {
        disposedOrder.add(1);
      });
      registry.registerResource(() {
        disposedOrder.add(2);
      });
      registry.registerResource(() {
        disposedOrder.add(3);
      });

      await registry.disposeAll();

      expect(disposedOrder, [3, 2, 1]);
    });

    test('repeated disposal is safe (idempotent)', () async {
      int disposeCount = 0;
      registry.registerResource(() {
        disposeCount++;
      });

      await registry.disposeAll();
      await registry.disposeAll();

      expect(disposeCount, 1);
    });

    test('repeated disposeByOwner is safe (idempotent)', () async {
      int disposeCount = 0;
      final owner = Object();
      registry.registerResource(() {
        disposeCount++;
      }, owner: owner);

      await registry.disposeByOwner(owner);
      await registry.disposeByOwner(owner);

      expect(disposeCount, 1);
    });

    test('disposeByOwner cleans up specific owner only', () async {
      final List<String> disposedList = [];
      final ownerA = 'ownerA';
      final ownerB = 'ownerB';

      registry.registerResource(() => disposedList.add('A1'), owner: ownerA);
      registry.registerResource(() => disposedList.add('B1'), owner: ownerB);
      registry.registerResource(() => disposedList.add('A2'), owner: ownerA);

      await registry.disposeByOwner(ownerA);

      expect(disposedList, ['A2', 'A1']);

      await registry.disposeByOwner(ownerB);
      expect(disposedList, ['A2', 'A1', 'B1']);
    });

    test('one failing disposer does not skip independent cleanup operations', () async {
      final List<int> disposedOrder = [];

      registry.registerResource(() {
        disposedOrder.add(1);
      });
      registry.registerResource(() {
        throw Exception('Boom');
      });
      registry.registerResource(() {
        disposedOrder.add(3);
      });

      await registry.disposeAll();

      expect(disposedOrder, [3, 1]);
    });

    test('late registrations for disposed owner are immediately disposed', () async {
      final owner = 'disposedOwner';
      await registry.disposeByOwner(owner);

      int syncDisposeCount = 0;
      registry.registerResource(() {
        syncDisposeCount++;
      }, owner: owner);

      expect(syncDisposeCount, 1, reason: 'Should immediately dispose synchronously');

      int asyncDisposeCount = 0;
      registry.registerResource(() async {
        asyncDisposeCount++;
      }, owner: owner);

      await Future.delayed(Duration.zero); // Let microtask run
      expect(asyncDisposeCount, 1, reason: 'Should immediately dispose asynchronously');
    });

    test('late registrations when completely disposed are immediately disposed', () async {
      await registry.disposeAll();

      int syncDisposeCount = 0;
      registry.registerResource(() {
        syncDisposeCount++;
      });

      expect(syncDisposeCount, 1, reason: 'Should immediately dispose synchronously');
    });

    test('abandoned subscriptions are properly tracked and disposed', () async {
      final streamController = StreamController<int>();
      bool wasCancelled = false;
      streamController.onCancel = () {
        wasCancelled = true;
      };

      final sub = streamController.stream.listen((_) {});
      registry.registerSubscription(sub);

      await registry.disposeAll();
      expect(wasCancelled, isTrue);
    });

    test('timers are cancelled upon disposeAll', () async {
      bool timerFired = false;
      final timer = Timer(const Duration(milliseconds: 100), () {
        timerFired = true;
      });

      registry.registerTimer(timer);

      await registry.disposeAll();
      await Future.delayed(const Duration(milliseconds: 150));

      expect(timerFired, isFalse);
    });

  });
}
