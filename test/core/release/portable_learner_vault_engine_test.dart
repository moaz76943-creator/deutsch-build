import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/release/portable_learner_vault_engine.dart';

void main() {
  group('PortableLearnerVaultEngine Tests', () {
    const engine = PortableLearnerVaultEngine();

    const samplePayload = LearnerExportPayload(
      learnerId: 'polyglot_user_007',
      totalMasteredCards: 1450,
      totalReviewTurns: 8200,
      retentionAverage: 0.942,
      activeLanguages: ['de', 'ar', 'fr'],
      rawDatabaseDumpJson: '{"tables":{"vocab":1450,"reviews":8200}}',
    );

    test('Exports encrypted .polyglot container with standard magic header', () {
      final vaultBytes = engine.exportToPortableVault(
        payload: samplePayload,
        userPassphrase: 'MasterSecretKey2026',
      );

      expect(vaultBytes.isNotEmpty, isTrue);
      final rawHeader = utf8.decode(vaultBytes.sublist(0, 17));
      expect(rawHeader, equals('POLYGLOT_VAULT_V3'));
    });

    test('Round-trip export and import flawlessly restores learner progress with correct password', () {
      final vaultBytes = engine.exportToPortableVault(
        payload: samplePayload,
        userPassphrase: 'MasterSecretKey2026',
      );

      final restored = engine.importFromPortableVault(
        vaultBytes: vaultBytes,
        userPassphrase: 'MasterSecretKey2026',
      );

      expect(restored.learnerId, equals('polyglot_user_007'));
      expect(restored.totalMasteredCards, equals(1450));
      expect(restored.retentionAverage, equals(0.942));
      expect(restored.activeLanguages, contains('de'));
    });

    test('Fails securely with FormatException when supplied with wrong passphrase', () {
      final vaultBytes = engine.exportToPortableVault(
        payload: samplePayload,
        userPassphrase: 'CorrectKey123',
      );

      expect(
        () => engine.importFromPortableVault(vaultBytes: vaultBytes, userPassphrase: 'WrongKey456'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
