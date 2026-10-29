import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/user_vault_security_service.dart';

class BetterMockCipher implements VaultCipher {
  bool shouldThrowKeyUnavailable = false;
  bool shouldTamperEnvelope = false;

  @override
  Future<Uint8List> encrypt(String recordId, Uint8List plaintext) async {
    if (shouldThrowKeyUnavailable) {
      throw KeyUnavailableException('Mock key unavailable');
    }
    if (shouldTamperEnvelope) {
      return Uint8List.fromList([3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]);
    }

    // envelope: [1] + 28 bytes padding + plaintext
    final result = <int>[1];
    for (var i = 0; i < 28; i++) result.add(0);
    result.addAll(plaintext);
    return Uint8List.fromList(result);
  }

  @override
  Future<Uint8List> decrypt(String recordId, Uint8List ciphertext) async {
    if (ciphertext.length < 29 || ciphertext[0] != 1) {
      throw CorruptRecordException('Invalid ciphertext');
    }
    return ciphertext.sublist(29);
  }
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('placeholder test', () async {
    expect(true, isTrue);
  });
}
