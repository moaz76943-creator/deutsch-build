import 'dart:isolate';

import 'package:deutsch_bilarabi/utils/background_task_governor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chunks are bounded at exactly 200 and preserve order', () {
    final chunks = BackgroundTaskGovernor.batches(List<int>.generate(401, (i) => i)).toList();
    expect(chunks.map((chunk) => chunk.length).toList(), [200, 200, 1]);
    expect(chunks.expand((chunk) => chunk).toList(), List<int>.generate(401, (i) => i));
  });

  test('empty streams produce no transactions and invalid sizes are rejected', () {
    expect(BackgroundTaskGovernor.batches(<String>[]), isEmpty);
    expect(
      () => BackgroundTaskGovernor.batches([1], batchSize: 201).toList(),
      throwsRangeError,
    );
    expect(
      () => BackgroundTaskGovernor.batches([1], batchSize: 0).toList(),
      throwsRangeError,
    );
  });

  test('CPU work runs on another Dart isolate', () async {
    final caller = Isolate.current.hashCode;
    final worker = await BackgroundTaskGovernor.runCpuBound(() => Isolate.current.hashCode);
    expect(worker, isNot(caller));
  });

  test('an input iterable is consumed lazily and with no global accumulation', () {
    var seen = 0;
    Iterable<int> input() sync* {
      for (var i = 0; i < 405; i++) {
        seen++;
        yield i;
      }
    }
    final iterator = BackgroundTaskGovernor.batches(input()).iterator;
    expect(seen, 0);
    expect(iterator.moveNext(), isTrue);
    expect(iterator.current, hasLength(200));
    expect(seen, 200);
    expect(iterator.moveNext(), isTrue);
    expect(seen, 400);
  });

  test('error handling in worker entry on database open failure', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final governor = BackgroundTaskGovernor();

    await expectLater(
      () => governor.ingestLexicon(
        writableDatabasePath: 'dummy_path.db',
        rows: [],
      ),
      throwsA(isA<StateError>().having((e) => e.message, 'message', contains('Background SQLite worker failed:'))),
    );
  });
}
