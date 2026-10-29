import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/speech/encrypted_audio_sample_vault.dart';

void main() {
  group('EncryptedAudioSampleVault Tests', () {
    late EncryptedAudioSampleVault vault;

    setUp(() {
      final key = Uint8List.fromList(utf8.encode('polyglot_32byte_audio_vault_key!'));
      vault = EncryptedAudioSampleVault(encryptionKey: key);
    });

    test('Encrypts audio recording and decrypts identically', () {
      final samplePcm = Uint8List.fromList([10, 20, 30, 40, 50]);
      const sampleId = 'sample_001';

      final saved = vault.saveSample(
        sampleId: sampleId,
        word: 'Handschuh',
        languageIso: 'de',
        rawPcm: samplePcm,
      );

      expect(saved, isTrue);
      expect(vault.samplesCount, equals(1));

      final retrieved = vault.getSample(sampleId);
      expect(retrieved, isNotNull);
      expect(retrieved, equals(samplePcm));
    });

    test('Derives obfuscated non-plain storage keys', () {
      final key = vault.deriveObfuscatedKey('sample_test');
      expect(key, isNot(contains('sample_test')));
      expect(key.length, equals(64));
    });
  });
}
