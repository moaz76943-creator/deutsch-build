import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/database/boot_integrity_guard.dart';

class MockHealthyChecker implements DatabaseHealthChecker {
  @override
  Future<String> runPragmaIntegrityCheck() async => 'ok';

  @override
  Future<int> getSchemaVersion() async => 2;

  @override
  Future<int> countRows(String tableName) async {
    if (tableName == 'core_lemmas') return 1000;
    if (tableName == 'core_sentences') return 3000;
    if (tableName == 'core_fts_index') return 4079;
    return 50;
  }

  @override
  Future<void> runVacuum() async {}
}

class MockCorruptedChecker implements DatabaseHealthChecker {
  @override
  Future<String> runPragmaIntegrityCheck() async => '*** in database user_version: file is encrypted or is not a database';

  @override
  Future<int> getSchemaVersion() async => 0;

  @override
  Future<int> countRows(String tableName) async => 0;

  @override
  Future<void> runVacuum() async {}
}

void main() {
  group('BootIntegrityGuard Cold-Start Tests', () {
    test('Healthy database returns operational report with healthy status', () async {
      final guard = BootIntegrityGuard(checker: MockHealthyChecker());
      final report = await guard.verifyAndPrepare();

      expect(report.isOperational, isTrue);
      expect(report.status, equals(DatabaseIntegrityStatus.healthy));
      expect(report.totalLemmas, equals(1000));
      expect(report.totalSentences, equals(3000));
      expect(report.totalFtsEntries, equals(4079));
    });

    test('Corrupted pragma returns corrupted status and error message', () async {
      final guard = BootIntegrityGuard(checker: MockCorruptedChecker());
      final report = await guard.verifyAndPrepare();

      expect(report.isOperational, isFalse);
      expect(report.status, equals(DatabaseIntegrityStatus.corrupted));
      expect(report.errorMessage, contains('PRAGMA integrity_check failed'));
    });
  });
}
