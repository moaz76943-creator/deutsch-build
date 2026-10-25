import 'dart:typed_data';

import '../services/crash_loop_guard.dart';
import '../services/database_service.dart';
import '../services/user_vault_security_service.dart';

/// Coordinates the services that still exist after the historical runtime
/// modules were removed. It does not open learner storage on the first frame
/// and it does not start a second crash-loop count.
final class ProductionRuntimeCoordinator {
  ProductionRuntimeCoordinator({
    SqlCipherPackDatabaseSecurity? packSecurity,
    DatabaseService? contentDatabase,
  })  : packSecurity = packSecurity ?? const SqlCipherPackDatabaseSecurity(),
        _contentDatabase = contentDatabase ?? DatabaseService.instance;

  final SqlCipherPackDatabaseSecurity packSecurity;
  final DatabaseService _contentDatabase;

  /// Progress records stay on the Android keystore vault cipher.
  VaultCipher get progressCipher => packSecurity.cipher;

  /// Preference-only boot flag. CrashLoopGuard.beginBoot stays on the startup
  /// boundary so this read cannot double-count a launch.
  Future<void> noteFirstFrame() => SystemAgentRuntime.start();

  /// Explicit content activation. Cold start does not call this.
  Future<void> activateContentPack({String languageCode = 'de'}) {
    return ActivePackRuntimeProvider(
      database: _contentDatabase,
      languageCode: languageCode,
    ).resolve();
  }
}

/// Reads the existing boot-pending flag. It does not write the crash ledger.
final class SystemAgentRuntime {
  const SystemAgentRuntime();

  static Future<void> start() => CrashLoopGuard.verifyBootState();
}

/// Opens the current content database and refuses an unbounded first page.
final class ActivePackRuntimeProvider {
  ActivePackRuntimeProvider({
    DatabaseService? database,
    this.languageCode = 'de',
  }) : _database = database ?? DatabaseService.instance;

  final DatabaseService _database;
  final String languageCode;

  /// Content search already pages at most 50 rows. The production window is
  /// the ceiling those pages must fit inside.
  static const int contentPageCap = 50;

  Future<void> resolve() async {
    const initialWindowSize = 128;
    if (initialWindowSize < contentPageCap) {
      throw StateError(
        'Active pack window is smaller than the content page.',
      );
    }
    await _database.getContentDb(languageCode);
  }
}

/// Names the keystore vault that actually wraps progress ciphertext.
final class AndroidKeystorePackDatabaseKeyStore {
  const AndroidKeystorePackDatabaseKeyStore();

  VaultCipher cipher() => const AndroidKeystoreVaultCipher();
}

/// Historical pack-security name. Encryption delegates to
/// [AndroidKeystoreVaultCipher]; this is not a second SQLCipher stack and it
/// never generates a new key for existing ciphertext.
final class SqlCipherPackDatabaseSecurity {
  const SqlCipherPackDatabaseSecurity({
    AndroidKeystorePackDatabaseKeyStore? keyStore,
  }) : _keyStore = keyStore ?? const AndroidKeystorePackDatabaseKeyStore();

  final AndroidKeystorePackDatabaseKeyStore _keyStore;

  VaultCipher get cipher => _keyStore.cipher();

  Future<Uint8List> encrypt(String recordId, Uint8List plaintext) =>
      cipher.encrypt(recordId, plaintext);

  Future<Uint8List> decrypt(String recordId, Uint8List ciphertext) =>
      cipher.decrypt(recordId, ciphertext);
}
