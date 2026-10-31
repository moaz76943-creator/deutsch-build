import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/lifecycle/runtime_lifecycle_registry.dart';

void main() {
  final registry = RuntimeLifecycleRegistry.instance;

  setUp(() {
    registry.resetForTesting();
  });
  tearDown(() async {
    await registry.disposeAll();
  });

  test('owner cleanup is LIFO, idempotent, and isolated', () async {
    final owner = LifecycleOwner();
    final other = LifecycleOwner();
    final disposed = <int>[];
    registry.registerResource(() => disposed.add(1), owner: owner);
    registry.registerResource(() => disposed.add(2), owner: other);
    registry.registerResource(() => disposed.add(3), owner: owner);
    await registry.disposeByOwner(owner);
    await registry.disposeByOwner(owner);
    expect(disposed, <int>[3, 1]);
    expect(registry.trackedResourceCount, 1);
    await registry.disposeByOwner(other);
    expect(disposed, <int>[3, 1, 2]);
  });

  test('disposed ownership cannot resurrect resources after many screens', () async {
    final first = LifecycleOwner();
    await registry.disposeByOwner(first);
    for (var index = 0; index < 10000; index++) {
      await registry.disposeByOwner(LifecycleOwner());
      await registry.disposeByOwner('old-screen-$index');
    }
    expect(registry.legacyTombstoneCount,
        lessThanOrEqualTo(RuntimeLifecycleRegistry.maxLegacyOwnerTombstones));
    var disposed = 0;
    registry.registerResource(() => disposed++, owner: first);
    expect(disposed, 1);
    expect(registry.trackedResourceCount, 0);
  });

  test('late subscriptions and timers are released', () async {
    final owner = LifecycleOwner();
    await registry.disposeByOwner(owner);
    final controller = StreamController<int>();
    var cancelled = false;
    controller.onCancel = () => cancelled = true;
    registry.registerSubscription(controller.stream.listen((_) {}),
        owner: owner);
    final timer = Timer(const Duration(seconds: 1), () {});
    registry.registerTimer(timer, owner: owner);
    await Future<void>.delayed(Duration.zero);
    expect(cancelled, isTrue);
    expect(timer.isActive, isFalse);
    await controller.close();
  });

  test('failed disposer does not prevent cleanup', () async {
    var disposed = false;
    registry.registerResource(() => disposed = true);
    registry.registerResource(() => throw StateError('bad disposer'));
    await registry.disposeAll();
    await registry.disposeAll();
    expect(disposed, isTrue);
    expect(registry.trackedResourceCount, 0);
  });

  test('registry refuses unbounded active allocations', () async {
    for (var i = 0; i < RuntimeLifecycleRegistry.maxTrackedResources; i++) {
      registry.registerResource(() {});
    }
    var discarded = false;
    expect(
        () => registry.registerResource(() => discarded = true),
        throwsStateError);
    expect(discarded, isTrue);
    expect(registry.trackedResourceCount,
        RuntimeLifecycleRegistry.maxTrackedResources);
  });
}
