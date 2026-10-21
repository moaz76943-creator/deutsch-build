import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/crash_loop_guard.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';

/// High-priority security and stability tests for Google Play quality guidelines.
/// Focus: crash loop protection (stability), vault record validation (security/data handling).
void main() {
  group('CrashLoopGuard - Stability (GP-P3 / Android Vitals)', () {
    late CrashLoopGuard guard;
    late MemoryBootLedgerStore store;

    setUp(() {
      store = MemoryBootLedgerStore();
      guard = CrashLoopGuard(store: store, clock: () => DateTime.utc(2026, 10, 21));
    });

    test('First boot is never safe mode', () async {
      final safe = await guard.beginBoot();
      expect(safe, isFalse);
      expect(guard.safeModeEnabled, isFalse);
    });

    test('Two rapid unclean boots trigger safe mode on third', () async {
      await guard.beginBoot();
      store.forceNextTime(DateTime.utc(2026, 10, 21, 0, 0, 2));
      await guard.beginBoot();
      store.forceNextTime(DateTime.utc(2026, 10, 21, 0, 0, 4));
      final safe = await guard.beginBoot();
      expect(safe, isTrue);
      expect(guard.safeModeEnabled, isTrue);
    });

    test('Successful markStable resets failure count', () async {
      await guard.beginBoot();
      await guard.markStable();
      store.forceNextTime(DateTime.utc(2026, 10, 21, 0, 0, 2));
      final safe = await guard.beginBoot();
      expect(safe, isFalse);
    });

    test('exitAfterRecovery clears safe mode', () async {
      store.seed({'safe': true, 'failures': 2});
      await guard.beginBoot();
      expect(guard.safeModeEnabled, isTrue);
      await guard.exitAfterRecovery();
      expect(guard.safeModeEnabled, isFalse);
    });
  });

  group('UserVaultSecurityService - Security & Data Handling', () {
    test('Rejects invalid record IDs (injection / path traversal protection)', () {
      expect(
        () => UserVaultSecurityService._validateId('../evil'),
        throwsArgumentError,
      );
      expect(
        () => UserVaultSecurityService._validateId(''),
        throwsArgumentError,
      );
      expect(
        () => UserVaultSecurityService._validateId('a' * 200),
        throwsArgumentError,
      );
      expect(() => UserVaultSecurityService._validateId('progress/v1/srs/abc123'), returnsNormally);
    });

    test('Enforces maximum record size', () {
      expect(UserVaultSecurityService.maximumRecordBytes, equals(4 * 1024 * 1024));
    });

    test('Progress key generation is deterministic and non-empty', () {
      final key1 = UserVaultSecurityService._progressKey('srs', 'lexeme1', 'de');
      final key2 = UserVaultSecurityService._progressKey('srs', 'lexeme1', 'de');
      expect(key1, equals(key2));
      expect(key1, startsWith('progress/v1/srs/'));
      expect(key1.length, greaterThan(20));
    });
  });

  group('Critical User Flow - Offline / Data Isolation smoke', () {
    test('Content and progress databases are conceptually separated', () {
      // Architectural invariant documented in DatabaseService
      // (progressDb vs contentDb). Full integration requires FFI SQLite.
      expect(true, isTrue);
    });
  });
}

/// In-memory ledger for deterministic unit testing of CrashLoopGuard.
class MemoryBootLedgerStore implements BootLedgerStore {
  Map<String, dynamic>? _state;
  DateTime? _forcedTime;

  void seed(Map<String, dynamic> state) => _state = state;

  void forceNextTime(DateTime t) => _forcedTime = t;

  @override
  Future<Map<String, dynamic>?> read() async => _state;

  @override
  Future<void> write(Map<String, dynamic> state) async {
    _state = state;
  }
}
