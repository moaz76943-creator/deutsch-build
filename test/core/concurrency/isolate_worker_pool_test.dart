import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/concurrency/isolate_worker_pool.dart';

// Top-level function for isolate computation test
int heavyFibonacci(int n) {
  if (n <= 1) return n;
  int a = 0, b = 1;
  for (int i = 2; i <= n; i++) {
    int c = a + b;
    a = b;
    b = c;
  }
  return b;
}

void main() {
  group('IsolateWorkerPool Tests', () {
    late IsolateWorkerPool pool;

    setUp(() {
      pool = IsolateWorkerPool(maxWorkers: 2);
    });

    tearDown(() {
      pool.dispose();
    });

    test('Offloads computational task and returns accurate result', () async {
      final result = await pool.execute(heavyFibonacci, 10);
      expect(result, equals(55));
    });

    test('Throws StateError if task is executed on disposed pool', () async {
      pool.dispose();
      expect(
        () => pool.execute(heavyFibonacci, 5),
        throwsA(isA<StateError>()),
      );
    });
  });
}
