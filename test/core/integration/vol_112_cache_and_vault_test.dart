import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/cache/semantic_cache_invalidation_bus.dart';
import 'package:deutsch_build/src/core/security/offline_pack_encryption_vault.dart';
import 'package:deutsch_build/src/ui/bridges/vol_112_wave2_ui_bridge.dart';

void main() {
  group('Volume 112 Wave 2 (Tasks 4836-4838) Cache & Encryption Tests', () {
    test('ARCH-005: SemanticCacheInvalidationBus dispatches and logs invalidations correctly', () {
      final bus = SemanticCacheInvalidationBus();
      bus.registerTagInterest('vocab_lesson_de_1');

      expect(bus.isTagRecentlyInvalidated('vocab_lesson_de_1'), isFalse);

      bus.dispatchInvalidation(
        eventId: 'evt_001',
        tags: {'vocab_lesson_de_1', 'grammar_de_a1'},
        originSubsystem: 'sync_engine',
      );

      expect(bus.dispatchedCount, equals(1));
      expect(bus.auditLogSize, equals(1));
      expect(bus.isTagRecentlyInvalidated('vocab_lesson_de_1'), isTrue);
      expect(bus.isTagRecentlyInvalidated('unrelated_tag'), isFalse);
    });

    test('SEC-004: OfflinePackEncryptionVault seals and unseals with integrity protection', () {
      final masterKey = Uint8List.fromList(List.generate(32, (i) => i * 7 % 256));
      final vault = OfflinePackEncryptionVault(deviceSecretKey: masterKey);

      final rawData = Uint8List.fromList(utf8.encode('Polyglot German A1 Complete Lesson Data'));
      final envelope = vault.sealPack('pack_de_a1', rawData);

      expect(envelope.packId, equals('pack_de_a1'));
      expect(envelope.cipherBytes.length, equals(rawData.length));
      expect(envelope.authenticationTagHex.isNotEmpty, isTrue);

      final decrypted = vault.unsealPack(envelope);
      expect(utf8.decode(decrypted), equals('Polyglot German A1 Complete Lesson Data'));

      // Tamper test: Altering 1 byte in cipher must trigger Fail-Closed VaultDecryptionException
      final tamperedCipher = Uint8List.fromList(envelope.cipherBytes);
      tamperedCipher[0] ^= 0xFF;
      final tamperedEnvelope = EncryptedPackEnvelope(
        packId: envelope.packId,
        initializationVectorHex: envelope.initializationVectorHex,
        authenticationTagHex: envelope.authenticationTagHex,
        cipherBytes: tamperedCipher,
      );

      expect(
        () => vault.unsealPack(tamperedEnvelope),
        throwsA(isA<VaultDecryptionException>()),
      );
    });

    test('UI Bridge generates accurate Wave 2 diagnostics report', () {
      final bridge = Vol112Wave2UIBridge();
      final report = bridge.getWave2Diagnostics();

      expect(report['volume'], equals(112));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
      expect(report['subsystems']['semantic_cache_bus']['status'], equals('ACTIVE'));
    });
  });
}
