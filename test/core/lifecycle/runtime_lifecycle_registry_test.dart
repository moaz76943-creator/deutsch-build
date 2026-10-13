import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/lifecycle/runtime_lifecycle_registry.dart';

void main() {
  final registry = RuntimeLifecycleRegistry.instance;
  setUp(registry.resetForTesting);
  tearDown(() async { await registry.disposeAll(); });

  test('LIFO cleanup is exactly once across repeated disposal', () async {
    final result = <int>[];
    registry.registerResource(() => result.add(1));
    registry.registerResource(() => result.add(2));
    await registry.disposeAll();
    await registry.disposeAll();
    expect(result, [2, 1]);
  });

  test('isolates disposal to owning session and rejects its late resources', () async {
    final owner = Object();
    final other = Object();
    var released = 0;
    registry.registerResource(() { released++; }, owner: owner);
    registry.registerResource(() { released += 10; }, owner: other);
    await registry.disposeByOwner(owner);
    await registry.disposeByOwner(owner);
    expect(released, 1);
    registry.registerResource(() { released++; }, owner: owner);
    expect(released, 2);
    await registry.disposeAll();
    expect(released, 12);
  });

  test('disposed owner tracking has an absolute memory bound', () async {
    for (var i = 0; i < 10000; i++) {
      await registry.disposeByOwner('screen_$i');
    }
    expect(registry.rememberedDisposedOwnerCount,
        RuntimeLifecycleRegistry.maxRememberedOwners);
  });

  test('one failing disposer does not block cleanup or leave timer running', () async {
    var invoked = false;
    final timer = Timer(const Duration(seconds: 30), () { invoked = true; });
    registry.registerTimer(timer);
    registry.registerResource(() { throw StateError('test failure'); });
    await registry.disposeAll();
    expect(timer.isActive, isFalse);
    expect(invoked, isFalse);
  });
  test('owner tokens reject stale late resources even after 10000 disposals', () async {
    final old = LifecycleOwnerToken();
    await registry.disposeByOwner(old);
    for (var i = 0; i < 10000; i++) {
      await registry.disposeByOwner(LifecycleOwnerToken());
    }
    var releasedImmediately = 0;
    registry.registerResource(() { releasedImmediately++; }, owner: old);
    expect(releasedImmediately, 1);
    expect(old.isDisposed, isTrue);
    expect(registry.rememberedDisposedOwnerCount, 0);
  });

}
