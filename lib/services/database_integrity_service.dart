import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'crash_loop_guard.dart';
import 'diagnostic_ledger_service.dart';

/// A damaged pack must not be used for queries until it has been rechecked.
class DatabaseIntegrityService {
  DatabaseIntegrityService({DiagnosticLedgerService? ledger})
      : _ledger = ledger ?? DiagnosticLedgerService.instance;

  static final DatabaseIntegrityService instance = DatabaseIntegrityService();

  final DiagnosticLedgerService _ledger;
  final ValueNotifier<Map<String, String>> _quarantine =
      ValueNotifier<Map<String, String>>(<String, String>{});

  ValueListenable<Map<String, String>> get quarantined => _quarantine;
  bool isQuarantined(String code) => _quarantine.value.containsKey(code);

  /// Checks the open, read-only pack before any lexicon query is allowed.
  /// Invalid responses and SQLite I/O errors are handled as quarantine.
  Future<bool> checkMountedPack(String code, Database database) async {
    try {
      await CrashLoopGuard.waitForIntegrityWindow();
      final rows = await database.rawQuery('PRAGMA quick_check(1);');
      if (rows.length == 1 &&
          rows.first.values.length == 1 &&
          rows.first.values.first.toString().toLowerCase() == 'ok') {
        clearQuarantine(code);
        return true;
      }
      await quarantine(code, StateError('SQLite quick_check did not return ok'));
    } catch (error) {
      await quarantine(code, error);
    }
    return false;
  }

  Future<void> quarantine(String code, Object error) async {
    if (!_quarantine.value.containsKey(code)) {
      _quarantine.value = Map<String, String>.unmodifiable(<String, String>{
        ..._quarantine.value,
        code: 'quarantined',
      });
    }
    await _ledger.record(
      category: 'sqlite_integrity',
      languageCode: code,
      error: error,
    );
  }

  void clearQuarantine(String code) {
    if (!isQuarantined(code)) return;
    final next = <String, String>{..._quarantine.value}..remove(code);
    _quarantine.value = Map<String, String>.unmodifiable(next);
  }

  /// Recovery hook for an existing atomic installer or a local re-mount.
  /// Reinstall must stage and replace files atomically, never mutate an open DB.
  Future<bool> recover({
    required String languageCode,
    required Future<Database> Function() remount,
    Future<void> Function()? closeMounted,
    Future<void> Function()? reinstall,
  }) async {
    try {
      if (closeMounted != null) await closeMounted();
      if (reinstall != null) await reinstall();
      final db = await remount();
      return checkMountedPack(languageCode, db);
    } catch (error) {
      await quarantine(languageCode, error);
      return false;
    }
  }
}
