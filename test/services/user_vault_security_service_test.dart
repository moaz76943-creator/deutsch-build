import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';

/// Cryptographic contract tests use a deterministic fake; actual Keystore
/// attestation/AES-GCM requires an Android instrumentation test.
class FakeCipher implements VaultCipher {
  @override
  Future<Uint8List> encrypt(String id,Uint8List data) async =>
      Uint8List.fromList(<int>[1,...List<int>.filled(28,0),
        ...data.map((value)=>value^0x55)]);
  @override
  Future<Uint8List> decrypt(String id,Uint8List data) async =>
      Uint8List.fromList(data.skip(29).map((value)=>value^0x55));
}
class BrokenCipher implements VaultCipher {
  @override
  Future<Uint8List> encrypt(String id,Uint8List data) async =>
      throw StateError('hardware unavailable');
  @override
  Future<Uint8List> decrypt(String id,Uint8List data) async =>
      throw StateError('hardware unavailable');
}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory=databaseFactoryFfi;
  late Database db;
  setUp(() async {
    db=await openDatabase(inMemoryDatabasePath);
    await db.execute('CREATE TABLE vault_entries ('
      'record_hash TEXT PRIMARY KEY, ciphertext BLOB NOT NULL)');
  });
  tearDown(() async =>db.close());

  test('encrypted roundtrip never persists plaintext or raw record id',() async {
    final vault=UserVaultSecurityService(
      cipher:FakeCipher(),openVaultDatabase:() async=>db);
    final content=Uint8List.fromList([65,66,67,68]);
    await vault.putRecord('srs:word-42',content);
    final rows=await db.query('vault_entries');
    expect(rows,hasLength(1));
    expect(rows.single['record_hash'],isNot('srs:word-42'));
    final blob=rows.single['ciphertext'] as Uint8List;
    expect(blob.contains(65),isFalse);
    expect(await vault.readRecord('srs:word-42'),orderedEquals(content));
    await vault.deleteRecord('srs:word-42');
    expect(await vault.readRecord('srs:word-42'),isNull);
  });
  test('crypto boundary failure prevents SQLite writes',() async {
    final vault=UserVaultSecurityService(
      cipher:BrokenCipher(),openVaultDatabase:() async=>db);
    expect(()=>vault.putRecord('notes:1',Uint8List.fromList([42])),
      throwsStateError);
    expect(await db.query('vault_entries'),isEmpty);
  });
  test('reject invalid identifiers and oversized records',() async {
    final vault=UserVaultSecurityService(
      cipher:FakeCipher(),openVaultDatabase:() async=>db);
    expect(()=>vault.putRecord('bad name',Uint8List(1)),
      throwsArgumentError);
    expect(()=>vault.putRecord('srs:1',
      Uint8List(UserVaultSecurityService.maximumRecordBytes+1)),
      throwsArgumentError);
  });
}
