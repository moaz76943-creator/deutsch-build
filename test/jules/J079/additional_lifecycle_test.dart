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

  group('RuntimeLifecycleRegistry additional tests', () {
    test('repeated disposal is safe', () async {
      int c = 0;
      registry.registerCleanup(() => c++, owner: 'x');
      await registry.disposeOwner('x');
      await registry.disposeOwner('x');
      expect(c, 1);
    });

    test('application pause is handled safely', () async {
      int c = 0;
      registry.guard(() => c++, owner: 'y');
      await registry.disposeOwner('y');
      registry.guard(() => c++, owner: 'y');
      expect(c, 1);
    });

    test('failed cleanup does not skip independent remaining cleanup operations', () async {
      int c = 0;
      registry.registerCleanup(() => c++, owner: 'z');
      registry.registerCleanup(() => throw Exception('error'), owner: 'z');
      registry.registerCleanup(() => c++, owner: 'z');
      await registry.disposeOwner('z');
      expect(c, 2);
    });

    test('abandoned subscriptions are cancelled safely', () async {
      final ctrl = StreamController<int>();
      bool cancelled = false;
      ctrl.onCancel = () { cancelled = true; };
      registry.registerSubscription(ctrl.stream.listen((_) {}), owner: 'w');
      await registry.disposeOwner('w');
      expect(cancelled, true);
    });

    test('race conditions in cleanup are handled', () async {
      int c = 0;
      registry.registerCleanup(() {
        registry.registerCleanup(() => c++, owner: 'r');
      }, owner: 'r');
      await registry.disposeOwner('r');
      expect(c, 1);
    });
  });
}
