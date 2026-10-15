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

      // Invalid signature length
      expect(
        Ed25519SignatureVerifier.verify(
          publicKeyBytes: dummyPub,
          messageBytes: dummyMsg,
          signatureBytes: Uint8List(32),
        ),
        isFalse,
      );
    });

    test('PackTrustRegistry trusts registered keys and honors revocation', () {
      const devKey = '3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c';
      expect(PackTrustRegistry.isKeyTrusted(devKey), isTrue);

      const untrustedKey = 'aabbccddeeff00112233445566778899aabbccddeeff00112233445566778899';
      expect(PackTrustRegistry.isKeyTrusted(untrustedKey), isFalse);

      PackTrustRegistry.registerTrustedKey('partner-dev', untrustedKey);
      expect(PackTrustRegistry.isKeyTrusted(untrustedKey), isTrue);

      PackTrustRegistry.revokeKey(untrustedKey);
      expect(PackTrustRegistry.isKeyTrusted(untrustedKey), isFalse);
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
    test('Development bypass in non-release mode', () {
      expect(
        AppCertVerifier.verifySignature(
          currentApkCertSha256: 'any_random_debug_signature',
          isReleaseMode: false,
        ),
        AppSignatureStatus.developmentBypass,
      );
    });

    test('Enforces authorized signature in release mode', () {
      const authorized = '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';
      expect(
        AppCertVerifier.verifySignature(
          currentApkCertSha256: authorized,
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
}
