import 'dart:isolate';

import 'package:deutsch_bilarabi/utils/background_task_governor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

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

  test('background sqlite worker handles and propagates unknown commands', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final token = RootIsolateToken.instance!;

    final readyPort = ReceivePort();

    // Call the worker entry function directly for testing
    sqliteWorkerEntryForTest([readyPort.sendPort, token, inMemoryDatabasePath]);

    final requestsPort = await readyPort.first;
    expect(requestsPort, isA<SendPort>());
    final workerSendPort = requestsPort as SendPort;

    // Now we can send an unknown command
    final replyPort = ReceivePort();
    workerSendPort.send(['unknownCommand', null, replyPort.sendPort]);

    final response = await replyPort.first;
    expect(response, isA<Map>());
    final responseMap = response as Map;
    expect(responseMap, containsPair('error', contains('Unknown background task')));
    replyPort.close();

    // Send an invalid format to insert
    final insertReplyPort = ReceivePort();
    workerSendPort.send(['insert', [{'id': '', 'surface': ''}], insertReplyPort.sendPort]);
    final insertResponse = await insertReplyPort.first;
    expect(insertResponse, isA<Map>());
    final insertResponseMap = insertResponse as Map;
    expect(insertResponseMap, containsPair('error', contains('Lexicon rows require nonempty id and surface')));
    insertReplyPort.close();

    // Close it
    final closeReplyPort = ReceivePort();
    workerSendPort.send(['close', null, closeReplyPort.sendPort]);
    await closeReplyPort.first;
    closeReplyPort.close();
    readyPort.close();
  });
}
