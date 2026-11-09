import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/lifecycle/lifecycle_disposer.dart';

void main() {
  group('LifecycleDisposer Additional J079 tests', () {
    test('Repeated disposal is safe and idempotent (J079)', () async {
      final disposer = LifecycleDisposer();
      int count = 0;
      disposer.addTeardown(() => count++);
      await disposer.dispose();
      await disposer.dispose();
      expect(count, 1);
    });

    test('Failed cleanup does not skip independent remaining cleanup operations (J079)', () async {
      final disposer = LifecycleDisposer();
      int count = 0;
      disposer.addTeardown(() => count++);
      disposer.addTeardown(() => throw Exception('err'));
      disposer.addTeardown(() => count++);
      await disposer.dispose();
      expect(count, 2);
    });

    test('Stale callbacks are prevented by guard (J079)', () async {
      final disposer = LifecycleDisposer();
      int count = 0;
      disposer.guard(() => count++);
      await disposer.dispose();
      disposer.guard(() => count++);
      expect(count, 1);
    });

    test('Stale futures are prevented by guardFuture (J079)', () async {
      final disposer = LifecycleDisposer();
      final c = Completer<int>();
      final f = disposer.guardFuture(c.future);
      await disposer.dispose();
      c.complete(1);
      final res = await f;
      expect(res, null);
    });

    test('LIFO deterministic shutdown order (J079)', () async {
      final disposer = LifecycleDisposer();
      final order = <int>[];
      disposer.addTeardown(() => order.add(1));
      disposer.addTeardown(() => order.add(2));
      disposer.addTeardown(() => order.add(3));
      await disposer.dispose();
      expect(order, [3, 2, 1]);
    });
  });
}
