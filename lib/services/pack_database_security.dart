import 'dart:io';

import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlcipher;

abstract interface class PackDatabaseCipher {
  Future<void> encryptPlaintextInPlace(
    File plaintextDatabase, {
    required String password,
  });
}

abstract interface class PackDatabaseOpener {
  Future<Database> openReadOnly(String path, {required String password});
}

final class UnavailablePackDatabaseCipher implements PackDatabaseCipher {
  const UnavailablePackDatabaseCipher();

  @override
  Future<void> encryptPlaintextInPlace(
    File plaintextDatabase, {
    required String password,
  }) {
    throw const PackDatabaseSecurityException(
      'pack_database_cipher_unavailable',
    );
  }
}

final class FactoryBackedPackDatabaseOpener implements PackDatabaseOpener {
  const FactoryBackedPackDatabaseOpener(this.factory);

  final DatabaseFactory factory;

  @override
  Future<Database> openReadOnly(String path, {required String password}) =>
      factory.openDatabase(
        path,
        options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
      );
}

final class SqlCipherPackDatabaseSecurity
    implements PackDatabaseCipher, PackDatabaseOpener {
  const SqlCipherPackDatabaseSecurity();

  static const List<int> _plainSqliteHeader = <int>[
    0x53,
    0x51,
    0x4c,
    0x69,
    0x74,
    0x65,
    0x20,
    0x66,
    0x6f,
    0x72,
    0x6d,
    0x61,
    0x74,
    0x20,
    0x33,
    0x00,
  ];

  @override
  Future<void> encryptPlaintextInPlace(
    File plaintextDatabase, {
    required String password,
  }) async {
    _requirePassword(password);
    if (!await plaintextDatabase.exists() ||
        await plaintextDatabase.length() <= _plainSqliteHeader.length) {
      throw const PackDatabaseSecurityException(
        'pack_plaintext_database_missing',
      );
    }

    final encrypted = File(plaintextDatabase.path + '.phase7-encrypted');
    final backup = File(plaintextDatabase.path + '.phase7-plaintext');
    if (await encrypted.exists()) await encrypted.delete();
    if (await backup.exists()) await backup.delete();

    Database? source;
    var attached = false;
    try {
      source = await sqlcipher.openDatabase(
        plaintextDatabase.path,
        singleInstance: false,
      );
      await _assertCipherEngine(source);
      final versionRows = await source.rawQuery('PRAGMA user_version');
      final userVersion = versionRows.isEmpty
          ? 0
          : ((versionRows.first.values.first as num?)?.toInt() ?? 0);

      await source.execute(
        "ATTACH DATABASE '" +
            _sqlLiteral(encrypted.path) +
            "' AS encrypted KEY '" +
            _sqlLiteral(password) +
            "'",
      );
      attached = true;
      await source.rawQuery("SELECT sqlcipher_export('encrypted')");
      await source.execute(
        'PRAGMA encrypted.user_version = ' + userVersion.toString(),
      );
      final cipherErrors = await source.rawQuery(
        'PRAGMA encrypted.cipher_integrity_check',
      );
      if (cipherErrors.isNotEmpty) {
        throw const PackDatabaseSecurityException(
          'pack_cipher_integrity_failed',
        );
      }
      await source.execute('DETACH DATABASE encrypted');
      attached = false;
      await source.close();
      source = null;

      await plaintextDatabase.rename(backup.path);
      try {
        await encrypted.rename(plaintextDatabase.path);
        await _assertEncryptedFile(plaintextDatabase, password: password);
        await backup.delete();
      } on Object {
        if (await plaintextDatabase.exists()) {
          await plaintextDatabase.delete();
        }
        if (await backup.exists()) {
          await backup.rename(plaintextDatabase.path);
        }
        rethrow;
      }
    } on PackDatabaseSecurityException {
      rethrow;
    } on Object {
      throw const PackDatabaseSecurityException(
        'pack_database_encryption_failed',
      );
    } finally {
      if (attached && source != null) {
        try {
          await source.execute('DETACH DATABASE encrypted');
        } on Object {
          // Closing the connection is the final cleanup boundary.
        }
      }
      if (source != null) {
        try {
          await source.close();
        } on Object {
          // Do not replace the original encryption error.
        }
      }
      if (await encrypted.exists()) {
        await encrypted.delete();
      }
    }
  }

  @override
  Future<Database> openReadOnly(String path, {required String password}) async {
    _requirePassword(password);
    Database? database;
    try {
      database = await sqlcipher.openDatabase(
        path,
        password: password,
        readOnly: true,
        singleInstance: false,
      );
      await _assertCipherEngine(database);
      await _assertIntegrity(database);
      return database;
    } on PackDatabaseSecurityException {
      if (database != null) await database.close();
      rethrow;
    } on Object {
      if (database != null) await database.close();
      throw const PackDatabaseSecurityException('pack_database_open_failed');
    }
  }

  Future<void> _assertEncryptedFile(
    File databaseFile, {
    required String password,
  }) async {
    final header = await databaseFile
        .openRead(0, _plainSqliteHeader.length)
        .fold<List<int>>(<int>[], (bytes, chunk) => bytes..addAll(chunk));
    if (_sameBytes(header, _plainSqliteHeader)) {
      throw const PackDatabaseSecurityException(
        'pack_database_plaintext_header_detected',
      );
    }
    final database = await openReadOnly(databaseFile.path, password: password);
    await database.close();
  }

  Future<void> _assertCipherEngine(Database database) async {
    final rows = await database.rawQuery('PRAGMA cipher_version');
    if (rows.isEmpty ||
        rows.first.values.isEmpty ||
        rows.first.values.first.toString().trim().isEmpty) {
      throw const PackDatabaseSecurityException(
        'pack_cipher_engine_unavailable',
      );
    }
  }

  Future<void> _assertIntegrity(Database database) async {
    final cipherErrors = await database.rawQuery(
      'PRAGMA cipher_integrity_check',
    );
    if (cipherErrors.isNotEmpty) {
      throw const PackDatabaseSecurityException('pack_cipher_integrity_failed');
    }
    final logical = await database.rawQuery('PRAGMA integrity_check');
    if (logical.isEmpty ||
        logical.first.values.isEmpty ||
        logical.first.values.first.toString().toLowerCase() != 'ok') {
      throw const PackDatabaseSecurityException('pack_sqlite_integrity_failed');
    }
  }

  static void _requirePassword(String password) {
    if (password.trim().isEmpty) {
      throw const PackDatabaseSecurityException('pack_database_key_missing');
    }
  }

  static String _sqlLiteral(String value) => value.replaceAll("'", "''");

  static bool _sameBytes(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}

final class PackDatabaseSecurityException implements Exception {
  const PackDatabaseSecurityException(this.code);

  final String code;

  @override
  String toString() => 'PackDatabaseSecurityException(' + code + ')';
}
