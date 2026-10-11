import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// No key bytes ever cross the Flutter platform channel.
/// Unsupported/non-hardware-backed keystores fail closed.
abstract class VaultCipher {
  Future<Uint8List> encrypt(String recordId, Uint8List plaintext);
  Future<Uint8List> decrypt(String recordId, Uint8List ciphertext);
}

class AndroidKeystoreVaultCipher implements VaultCipher {
  const AndroidKeystoreVaultCipher();
  static const MethodChannel _channel =
      MethodChannel('com.deutschbilarabi.app/user_vault_security');
  @override
  Future<Uint8List> encrypt(String recordId, Uint8List plaintext) async {
    final data = await _channel.invokeMethod<Uint8List>(
      'encrypt', <String,Object>{'recordId':recordId,'bytes':plaintext});
    if(data==null) throw StateError('Hardware vault unavailable');
    return data;
  }
  @override
  Future<Uint8List> decrypt(String recordId, Uint8List ciphertext) async {
    final data = await _channel.invokeMethod<Uint8List>(
      'decrypt', <String,Object>{'recordId':recordId,'bytes':ciphertext});
    if(data==null) throw StateError('Vault decryption failed');
    return data;
  }
}

/// Opt-in encrypted record vault. This does not silently rewrite legacy
/// user_progress_v2.db, which needs a separate, lossless migration.
class UserVaultSecurityService {
  UserVaultSecurityService({
    VaultCipher? cipher,
    Future<Database> Function()? openVaultDatabase,
  }) : _cipher=cipher ?? const AndroidKeystoreVaultCipher(),
       _openDatabase=openVaultDatabase ?? _openDefault;
  static const maximumRecordBytes=4*1024*1024;
  final VaultCipher _cipher;
  final Future<Database> Function() _openDatabase;
  Future<Database>? _cached;

  static Future<Database> _openDefault() async {
    final root=await getDatabasesPath();
    return openDatabase(path.join(root,'user_vault_v1.db'),version:1,
      onCreate:(db,_) async {
        await db.execute('CREATE TABLE vault_entries ('
          'record_hash TEXT PRIMARY KEY, ciphertext BLOB NOT NULL)');
      });
  }

  Future<Database> get _db=>_cached ??= _openDatabase();

  static void _validateId(String id) {
    if(!RegExp(r'^[a-zA-Z0-9_.:/-]{1,128}$').hasMatch(id)) {
      throw ArgumentError.value(id,'recordId','Invalid vault record ID');
    }
  }

  static String _index(String id)=>sha256.convert(utf8.encode(id)).toString();

  Future<void> putRecord(String id,Uint8List plaintext) async {
    _validateId(id);
    if(plaintext.length>maximumRecordBytes) {
      throw ArgumentError.value(plaintext.length,'plaintext','Record too large');
    }
    // Encryption completes before any SQLite write.
    final ciphertext=await _cipher.encrypt(id,plaintext);
    if(ciphertext.length < 29 || ciphertext[0]!=1) {
      throw StateError('Invalid encrypted vault envelope');
    }
    final database=await _db;
    await database.insert('vault_entries',<String,Object>{
      'record_hash':_index(id),'ciphertext':ciphertext,
    },conflictAlgorithm:ConflictAlgorithm.replace);
  }

  Future<Uint8List?> readRecord(String id) async {
    _validateId(id);
    final database=await _db;
    final rows=await database.query('vault_entries',
      columns:<String>['ciphertext'],
      where:'record_hash = ?',whereArgs:<Object>[_index(id)],limit:1);
    if(rows.isEmpty)return null;
    final encrypted=rows.single['ciphertext'];
    if(encrypted is! Uint8List || encrypted.length<29 || encrypted[0]!=1) {
      throw StateError('Vault record is corrupt');
    }
    return _cipher.decrypt(id,encrypted);
  }

  Future<void> deleteRecord(String id) async {
    _validateId(id);
    await (await _db).delete('vault_entries',
      where:'record_hash = ?',whereArgs:<Object>[_index(id)]);
  }
}
