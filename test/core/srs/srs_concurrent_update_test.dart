import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

class MockSrsStorage {
  int counter = 0;
  Future<void> _lock = Future.value();

  Future<int> concurrentIncrement() {
    final completer = Completer<int>();
    _lock = _lock.then((_) async {
      // Simulate asynchronous IO delay within same tick
      await Future.delayed(const Duration(milliseconds: 5));
      counter++;
      completer.complete(counter);
    });
    return completer.future;
  }
}

void main() {
  test('Prevents same-tick concurrent SRS update loss via serial write lock', () async {
    final storage = MockSrsStorage();
    const concurrentWrites = 50;

    // Dispatch 50 concurrent updates in the exact same microtask tick
    final futures = List.generate(concurrentWrites, (_) => storage.concurrentIncrement());
    final results = await Future.wait(futures);

    expect(storage.counter, equals(concurrentWrites));
    expect(results.last, equals(concurrentWrites));
  });
}
