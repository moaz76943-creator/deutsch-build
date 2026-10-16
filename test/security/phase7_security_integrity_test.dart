import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:archive/archive.dart';

import 'package:deutsch_bilarabi/core/security/secure_archive_extractor.dart';
import 'package:deutsch_bilarabi/core/security/ed25519_signature_verifier.dart';
import 'package:deutsch_bilarabi/core/security/monotonic_clock_guard.dart';
import 'package:deutsch_bilarabi/core/security/crypto_audit_chain.dart';
import 'package:deutsch_bilarabi/core/security/secret_memory_zeroizer.dart';
import 'package:deutsch_bilarabi/core/security/aead_backup_crypto.dart';
import 'package:deutsch_bilarabi/core/security/security_log_redactor.dart';
import 'package:deutsch_bilarabi/core/database/crash_safe_snapshot_manager.dart';
import 'package:deutsch_bilarabi/core/security/app_cert_verifier.dart';
import 'package:deutsch_bilarabi/core/storage/pack_admission_service.dart';

void main() {
  group('SecureArchiveExtractor Tests (Study 42 - Zip Slip & Bomb Protection)', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('secure_extract_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Rejects Zip Slip path traversals', () {
      expect(
        () => SecureArchiveExtractor.validateEntryPath('../malicious.txt', tempDir),
        throwsA(isA<ZipSlipException>()),
      );
      expect(
        () => SecureArchiveExtractor.validateEntryPath('/etc/passwd', tempDir),
        throwsA(isA<ZipSlipException>()),
      );
      expect(
        () => SecureArchiveExtractor.validateEntryPath('safe/../../root.txt', tempDir),
        throwsA(isA<ZipSlipException>()),
      );
      expect(
        () => SecureArchiveExtractor.validateEntryPath('file\x00traversal.txt', tempDir),
        throwsA(isA<ZipSlipException>()),
      );
    });

    test('Allows safe relative paths', () {
      expect(
        () => SecureArchiveExtractor.validateEntryPath('content/content.sqlite', tempDir),
        returnsNormally,
      );
      expect(
        () => SecureArchiveExtractor.validateEntryPath('metadata/pack.json', tempDir),
        returnsNormally,
      );
    });

    test('Safely extracts legitimate zip archive', () async {
      final archive = Archive();
      final content = utf8.encode('{"valid": true}');
      archive.addFile(ArchiveFile('metadata/pack.json', content.length, content));
      final zipBytes = Uint8List.fromList(ZipEncoder().encode(archive)!);

      final outDir = Directory('${tempDir.path}/extracted');
      final result = await SecureArchiveExtractor.extractZipBytes(
        zipBytes: zipBytes,
        destinationDir: outDir,
      );

      expect(result.totalEntriesExtracted, 1);
      final extractedFile = File('${outDir.path}/metadata/pack.json');
      expect(await extractedFile.exists(), isTrue);
      expect(await extractedFile.readAsString(), '{"valid": true}');
    });

    test('Rejects decompression bomb exceeding total bytes limit', () async {
      final archive = Archive();
      final content = Uint8List(2048); // 2 KB
      archive.addFile(ArchiveFile('huge.bin', content.length, content));
      final zipBytes = Uint8List.fromList(ZipEncoder().encode(archive)!);

      final outDir = Directory('${tempDir.path}/extracted_bomb');
      expect(
        () => SecureArchiveExtractor.extractZipBytes(
          zipBytes: zipBytes,
          destinationDir: outDir,
          maxTotalBytes: 1024, // limit to 1 KB
        ),
        throwsA(isA<DecompressionBombException>()),
      );

      // Staging directory should be cleaned up
      if (await outDir.exists()) {
        final list = await outDir.list().toList();
        expect(list.where((f) => f.path.contains('.staging_')), isEmpty);
      }
    });
  });

  group('Ed25519SignatureVerifier & PackTrustRegistry Tests (Study 06)', () {
    setUp(() {
      PackTrustRegistry.clearRegistryForTesting();
    });

    test('RFC 8032 Test Vector 1 positive verification (empty message)', () {
      final pubKey = PackTrustRegistry.hexToBytes(
        'd75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a',
      )!;
      final msg = Uint8List(0); // empty message
      final sig = PackTrustRegistry.hexToBytes(
        'e5564300c360ac729086e2cc806e828a84877f1eb8e5d974d873e065224901555fb8821590a33bacc61e39701cf9b46bd25bf5f0595bbe24655141438e7a100b',
      )!;

      expect(
        Ed25519SignatureVerifier.verify(
          publicKeyBytes: pubKey,
          messageBytes: msg,
          signatureBytes: sig,
        ),
        isTrue,
      );
    });

    test('RFC 8032 Test Vector 2 positive verification (1-byte message 0x72)', () {
      final pubKey = PackTrustRegistry.hexToBytes(
        '3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c',
      )!;
      final msg = Uint8List.fromList([0x72]);
      final sig = PackTrustRegistry.hexToBytes(
        '92a009a9f0d4cab8720e820b5f642540a2b27b5416503f8fb3762223ebdb69da085ac1e43e15996e458f3613d0f11d8c387b2eaeb4302aeeb00d291612bb0c00',
      )!;

      expect(
        Ed25519SignatureVerifier.verify(
          publicKeyBytes: pubKey,
          messageBytes: msg,
          signatureBytes: sig,
        ),
        isTrue,
      );
    });

    test('Rejects corrupted signature length or mismatched digest', () {
      final dummyPub = Uint8List(32);
      final dummyMsg = Uint8List.fromList(utf8.encode('Test message'));
      final dummySig = Uint8List(64);

      // All zeroes is not a valid signature on Curve25519
      expect(
        Ed25519SignatureVerifier.verify(
          publicKeyBytes: dummyPub,
          messageBytes: dummyMsg,
          signatureBytes: dummySig,
        ),
        isFalse,
      );

      // Invalid signature length (32 bytes instead of 64)
      expect(
        Ed25519SignatureVerifier.verify(
          publicKeyBytes: dummyPub,
          messageBytes: dummyMsg,
          signatureBytes: Uint8List(32),
        ),
        isFalse,
      );

      // Invalid public key length (31 bytes instead of 32)
      expect(
        Ed25519SignatureVerifier.verify(
          publicKeyBytes: Uint8List(31),
          messageBytes: dummyMsg,
          signatureBytes: dummySig,
        ),
        isFalse,
      );
    });

    test('Negative test: bit flips in signature, message, or public key invalidate verification', () {
      final pubKey = PackTrustRegistry.hexToBytes(
        'd75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a',
      )!;
      final msg = Uint8List(0);
      final sig = PackTrustRegistry.hexToBytes(
        'e5564300c360ac729086e2cc806e828a84877f1eb8e5d974d873e065224901555fb8821590a33bacc61e39701cf9b46bd25bf5f0595bbe24655141438e7a100b',
      )!;

      // 1. Bit flip in signature
      final tamperedSig = Uint8List.fromList(sig);
      tamperedSig[0] ^= 0x01;
      expect(
        Ed25519SignatureVerifier.verify(
          publicKeyBytes: pubKey,
          messageBytes: msg,
          signatureBytes: tamperedSig,
        ),
        isFalse,
      );

      // 2. Tampered message
      final tamperedMsg = Uint8List.fromList([0xFF]);
      expect(
        Ed25519SignatureVerifier.verify(
          publicKeyBytes: pubKey,
          messageBytes: tamperedMsg,
          signatureBytes: sig,
        ),
        isFalse,
      );

      // 3. Bit flip in public key
      final tamperedPub = Uint8List.fromList(pubKey);
      tamperedPub[0] ^= 0x01;
      expect(
        Ed25519SignatureVerifier.verify(
          publicKeyBytes: tamperedPub,
          messageBytes: msg,
          signatureBytes: sig,
        ),
        isFalse,
      );
    });

    test('PackTrustRegistry rejects known RFC 8032 test keys and prevents their registration', () {
      const devKey = '3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c';
      // Known RFC test key must NEVER be trusted in production registry
      expect(PackTrustRegistry.isKeyTrusted(devKey), isFalse);

      // Attempting to register known RFC 8032 test key throws ArgumentError
      expect(
        () => PackTrustRegistry.registerTrustedKey('dev-publisher', devKey),
        throwsArgumentError,
      );

      // Unregistered key is not trusted
      const partnerKey = 'aabbccddeeff00112233445566778899aabbccddeeff00112233445566778899';
      expect(PackTrustRegistry.isKeyTrusted(partnerKey), isFalse);

      // Registering legitimate key succeeds
      PackTrustRegistry.registerTrustedKey('partner-official', partnerKey);
      expect(PackTrustRegistry.isKeyTrusted(partnerKey), isTrue);

      // Revocation works
      PackTrustRegistry.revokeKey(partnerKey);
      expect(PackTrustRegistry.isKeyTrusted(partnerKey), isFalse);
    });
  });

  group('MonotonicClockGuard Tests (Study 24 - Tamper Detection)', () {
    test('Clamps backwards time travel to last persisted checkpoint', () {
      final checkpoint = DateTime.utc(2026, 10, 15, 12, 0, 0);
      final guard = MonotonicClockGuard(lastPersistedTimestamp: checkpoint);

      // Turn clock backward by 2 hours
      final tamperedPast = DateTime.utc(2026, 10, 15, 10, 0, 0);
      expect(guard.isBackwardsTimeTampered(tamperedPast), isTrue);

      final effective = guard.getEffectiveUtcTime(tamperedPast);
      // Effective time must NOT be in the past before checkpoint
      expect(effective.isBefore(checkpoint), isFalse);
    });

    test('Detects forward jump anomaly exceeding 365 days', () {
      final now = DateTime.utc(2026, 10, 15, 12, 0, 0);
      final guard = MonotonicClockGuard(lastPersistedTimestamp: now);

      // Normal next day
      expect(guard.isForwardAnomaly(DateTime.utc(2026, 10, 16, 12, 0, 0)), isFalse);

      // Jumping 2 years ahead
      expect(guard.isForwardAnomaly(DateTime.utc(2028, 10, 15, 12, 0, 0)), isTrue);
    });
  });

  group('CryptoAuditChain Tests (Study 66 - Tamper-Evident Ledgers)', () {
    test('Creates valid hash chain and verifies unbroken integrity', () {
      final chain = CryptoAuditChain();
      chain.appendEvent(
        eventType: 'srs_review',
        payload: {'lexeme_id': 'lex_101', 'rating': 4},
        timestamp: DateTime.utc(2026, 10, 15, 12, 0, 0),
      );
      chain.appendEvent(
        eventType: 'srs_review',
        payload: {'lexeme_id': 'lex_102', 'rating': 5},
        timestamp: DateTime.utc(2026, 10, 15, 12, 5, 0),
      );
      chain.appendEvent(
        eventType: 'milestone_unlocked',
        payload: {'milestone': 'a1_complete'},
        timestamp: DateTime.utc(2026, 10, 15, 12, 10, 0),
      );

      expect(chain.length, 3);
      final result = CryptoAuditChain.verifyChain(chain.blocks);
      expect(result.isValid, isTrue);
    });

    test('Detects tampered event payload retroactively', () {
      final chain = CryptoAuditChain();
      chain.appendEvent(
        eventType: 'srs_review',
        payload: {'rating': 3},
        timestamp: DateTime.utc(2026, 10, 15, 12, 0, 0),
      );
      chain.appendEvent(
        eventType: 'srs_review',
        payload: {'rating': 5},
        timestamp: DateTime.utc(2026, 10, 15, 12, 1, 0),
      );

      final originalBlocks = chain.blocks;
      // Tamper with first block payload
      final tampered = [
        AuditChainBlock(
          index: originalBlocks[0].index,
          timestampIso: originalBlocks[0].timestampIso,
          eventType: originalBlocks[0].eventType,
          payloadJson: jsonEncode({'rating': 5}), // forged score!
          previousHash: originalBlocks[0].previousHash,
          blockHash: originalBlocks[0].blockHash,
        ),
        originalBlocks[1],
      ];

      final result = CryptoAuditChain.verifyChain(tampered);
      expect(result.isValid, isFalse);
      expect(result.brokenAtIndex, 0);
    });
  });

  group('SecretMemoryZeroizer Tests (Study 54 - Memory Key Wiping)', () {
    test('Zeroizes byte buffer in place', () {
      final key = Uint8List.fromList([1, 2, 3, 4, 5]);
      SecretMemoryZeroizer.zeroize(key);
      expect(key, everyElement(equals(0)));
    });

    test('Guarantees zeroization even when exception is thrown', () {
      final secret = Uint8List.fromList([10, 20, 30, 40]);
      try {
        SecretMemoryZeroizer.withProtectedSecret(
          secretBytes: secret,
          action: (bytes) {
            throw StateError('Simulated crypto failure');
          },
        );
      } catch (_) {}

      expect(secret, everyElement(equals(0)));
    });
  });

  group('AeadBackupCrypto Tests (Study 18 - AEAD Encrypted Backups)', () {
    test('Encrypts and decrypts user progress backup with password', () {
      final rawData = utf8.encode('{"records": [{"id": 1, "status": "learned"}]}');
      const password = 'CorrectHorseBatteryStaple!2026';

      final envelope = AeadBackupCrypto.encryptPayload(
        plaintextBytes: Uint8List.fromList(rawData),
        password: password,
      );

      expect(envelope.version, 1);
      expect(envelope.kdf, 'PBKDF2-HMAC-SHA256');

      final decrypted = AeadBackupCrypto.decryptEnvelope(
        envelope: envelope,
        password: password,
      );

      expect(utf8.decode(decrypted), utf8.decode(rawData));
    });

    test('Rejects decryption with wrong password (AEAD auth failure)', () {
      final rawData = utf8.encode('{"secret": "progress"}');
      final envelope = AeadBackupCrypto.encryptPayload(
        plaintextBytes: Uint8List.fromList(rawData),
        password: 'Password123!',
      );

      expect(
        () => AeadBackupCrypto.decryptEnvelope(
          envelope: envelope,
          password: 'WrongPassword!',
        ),
        throwsA(isA<AeadCryptoException>()),
      );
    });

    test('Rejects tampered ciphertext with auth tag failure', () {
      final rawData = utf8.encode('{"data": 42}');
      final envelope = AeadBackupCrypto.encryptPayload(
        plaintextBytes: Uint8List.fromList(rawData),
        password: 'SecureKey999!',
      );

      // Flip first byte of ciphertext
      final tamperedCiphertext = 'ff' + envelope.ciphertextHex.substring(2);
      final forgedEnvelope = AeadBackupEnvelope(
        version: envelope.version,
        kdf: envelope.kdf,
        iterations: envelope.iterations,
        saltHex: envelope.saltHex,
        ivHex: envelope.ivHex,
        ciphertextHex: tamperedCiphertext,
        authTagHex: envelope.authTagHex,
        associatedData: envelope.associatedData,
      );

      expect(
        () => AeadBackupCrypto.decryptEnvelope(
          envelope: forgedEnvelope,
          password: 'SecureKey999!',
        ),
        throwsA(isA<AeadCryptoException>()),
      );
    });
  });

  group('SecurityLogRedactor Tests (Log Sanitization)', () {
    test('Redacts Bearer tokens and sensitive key values', () {
      const log1 = 'Request with Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.test and key=secret123';
      final redacted = SecurityLogRedactor.redact(log1);
      expect(redacted.contains('eyJhbGciOiJIUzI1NiJ9'), isFalse);
      expect(redacted.contains('secret123'), isFalse);
      expect(redacted.contains('[REDACTED'), isTrue);
    });
  });

  group('CrashSafeSnapshotManager Tests (Study 36 - SQLite Header)', () {
    test('Verifies valid and rejects corrupted SQLite headers', () async {
      final tempDir = await Directory.systemTemp.createTemp('sqlite_header_test_');
      try {
        final validFile = File('${tempDir.path}/valid.sqlite');
        await validFile.writeAsBytes(CrashSafeSnapshotManager.sqliteHeaderBytes + List.filled(84, 0));
        expect(await CrashSafeSnapshotManager.verifySqliteHeader(validFile), isTrue);

        final corruptFile = File('${tempDir.path}/corrupt.sqlite');
        await corruptFile.writeAsBytes(utf8.encode('NOT_A_SQLITE_HEADER_1234567890'));
        expect(await CrashSafeSnapshotManager.verifySqliteHeader(corruptFile), isFalse);
      } finally {
        await tempDir.delete(recursive: true);
      }
    });
  });

  group('AppCertVerifier Tests (Study 30 - APK Signature Validation)', () {
    setUp(() {
      AppCertVerifier.clearAuthorizedCertificatesForTesting();
    });

    test('Development bypass in non-release mode', () {
      expect(
        AppCertVerifier.verifySignature(
          currentApkCertSha256: 'any_random_debug_signature',
          isReleaseMode: false,
        ),
        AppSignatureStatus.developmentBypass,
      );
    });

    test('Rejects placeholder certificates in release mode', () {
      const placeholder = '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';
      expect(
        AppCertVerifier.verifySignature(
          currentApkCertSha256: placeholder,
          isReleaseMode: true,
        ),
        AppSignatureStatus.untrustedSignature,
      );

      // Attempting to register placeholder cert throws ArgumentError
      expect(
        () => AppCertVerifier.registerAuthorizedCertificate(placeholder),
        throwsArgumentError,
      );
    });

    test('Enforces authorized signature in release mode', () {
      const genuineCertSha256 = 'c0ffee112233445566778899aabbccddeeff00112233445566778899aabbccdd';
      AppCertVerifier.registerAuthorizedCertificate(genuineCertSha256);

      expect(
        AppCertVerifier.verifySignature(
          currentApkCertSha256: genuineCertSha256,
          isReleaseMode: true,
        ),
        AppSignatureStatus.verifiedRelease,
      );

      expect(
        AppCertVerifier.verifySignature(
          currentApkCertSha256: 'unauthorized_hacked_signature',
          isReleaseMode: true,
        ),
        AppSignatureStatus.untrustedSignature,
      );
    });
  });

  group('PackAdmissionService Signature Verification (Production Path)', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('pack_admission_sig_test_');
      PackTrustRegistry.clearRegistryForTesting();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('verifyPackSignature rejects untrusted or known RFC test keys', () async {
      final dummyFile = File('${tempDir.path}/test.pack');
      await dummyFile.writeAsBytes([0x72]);

      const rfcTestKey = '3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c';
      const rfcSig = '92a009a9f0d4cab8720e820b5f642540a2b27b5416503f8fb3762223ebdb69da085ac1e43e15996e458f3613d0f11d8c387b2eaeb4302aeeb00d291612bb0c00';

      // Known RFC test key must be rejected by PackAdmissionService
      final result = await PackAdmissionService.verifyPackSignature(
        packFile: dummyFile,
        signatureHex: rfcSig,
        publicKeyHex: rfcTestKey,
      );
      expect(result, isFalse);
    });

    test('verifyPackSignature verifies authentic pack signed by registered trusted publisher', () async {
      final packFile = File('${tempDir.path}/arabic_a1.pack');
      // Content matching 0-byte message or 0x72
      await packFile.writeAsBytes([0x72]);

      const publisherKey = '79b5562e8fe654f94078b112e8a98ba7901f853ae695bed7e0e3910bad049664';
      const validSig = '5b907d912cbb0218bfaddf03f37a5c22ead245bc0fb919b7c2611670e780a7f04385df80ced9d1eca74886dfb16545c8bca04220e6c53453055abe886c1d4a0e';

      // Register legitimate partner key
      PackTrustRegistry.registerTrustedKey('official-test-publisher', publisherKey);

      final result = await PackAdmissionService.verifyPackSignature(
        packFile: packFile,
        signatureHex: validSig,
        publicKeyHex: publisherKey,
      );
      expect(result, isTrue);
    });
  });
}
