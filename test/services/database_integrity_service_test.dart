import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/database_integrity_service.dart';
import 'package:deutsch_bilarabi/services/diagnostic_ledger_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory directory;
  late DatabaseIntegrityService service;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('integrity_test_');
    service = DatabaseIntegrityService(
      ledger: DiagnosticLedgerService(cacheDirectory: directory),
    );
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test('healthy pack passes quick_check and clears quarantine', () async {
    final db = await openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await service.quarantine('de', StateError('old failure'));
    expect(service.isQuarantined('de'), isTrue);
    expect(await service.checkMountedPack('de', db), isTrue);
    expect(service.isQuarantined('de'), isFalse);
  });

  test('closed SQLite connection is quarantined without uncaught error', () async {
    final db = await openDatabase(inMemoryDatabasePath);
    await db.close();
    expect(await service.checkMountedPack('fi', db), isFalse);
    expect(service.isQuarantined('fi'), isTrue);
    final exported = await DiagnosticLedgerService(
      cacheDirectory: directory,
    ).exportFile();
    expect(await exported.readAsString(), contains('sqlite_integrity'));
  });

  test('failed re-mount stays quarantined for a clean reinstall', () async {
    expect(
      await service.recover(
        languageCode: 'de',
        remount: () async => throw FileSystemException('missing'),
      ),
      isFalse,
    );
    expect(service.isQuarantined('de'), isTrue);
  });

  test('diagnostic journal stays within two MiB and keeps newest records', () async {
    final ledger = DiagnosticLedgerService(cacheDirectory: directory);
    for (var i = 0; i < 40; i++) {
      await ledger.record(
        category: 'sqlite_write',
        languageCode: 'de',
        error: '$i ${'X' * 70000}',
      );
    }
    final file = await ledger.exportFile();
    expect(await file.length(), lessThanOrEqualTo(DiagnosticLedgerService.maximumBytes));
    expect(await file.readAsString(), contains('39 '));
  });
}
