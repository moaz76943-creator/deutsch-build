import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/core/storage/crash_resilient_store.dart';

void main() {
  group('CrashResilientStore Interrupted Write Recovery', () {
    late Directory tempDir;
    late String testPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('srs_recovery_test_');
      testPath = '${tempDir.path}/user_progress.json';
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Recovers last-known-good progress if primary write was interrupted (zero-byte crash)', () async {
      final store = CrashResilientStore(testPath);

      // 1. Initial valid learning session write
      await store.saveAtomically({
        'pairId': 'de_ar',
        'reviewedCards': 42,
        'masteryScore': 0.85,
      });

      // 2. Simulate process kill mid-write causing zero-byte file corruption
      final corruptedPrimary = File(testPath);
      await corruptedPrimary.writeAsString('', flush: true);
      expect(await corruptedPrimary.length(), equals(0));

      // 3. Read back using recovery logic
      final recoveredData = await store.readWithRecovery();

      // 4. Assert full recovery from last-known-good backup
      expect(recoveredData['reviewedCards'], equals(42));
      expect(recoveredData['masteryScore'], equals(0.85));
      expect(await corruptedPrimary.length(), greaterThan(0));
    });
  });
}
