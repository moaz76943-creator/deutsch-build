import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Hardware security tier available on host Android device.
enum HardwareSecurityTier {
  strongBoxHsm, // Dedicated Secure Element / Titan M chip (Highest)
  trustedExecutionEnvironment, // TEE (Arm TrustZone)
  softwareFallback, // Software Keystore fallback
}

/// Metadata describing hardware-backed key attributes.
class HardwareKeyMetadata {
  final String keyAlias;
  final HardwareSecurityTier tier;
  final bool isStrongBoxBacked;
  final bool isUserAuthenticationRequired;
  final DateTime createdAt;

  const HardwareKeyMetadata({
    required this.keyAlias,
    required this.tier,
    required this.isStrongBoxBacked,
    this.isUserAuthenticationRequired = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'keyAlias': keyAlias,
    'tier': tier.name,
    'isStrongBoxBacked': isStrongBoxBacked,
    'isUserAuthenticationRequired': isUserAuthenticationRequired,
    'createdAt': createdAt.toIso8601String(),
  };
}

/// Platform bridge contract for native Android KeyStore / StrongBox Keymaster.
abstract class AndroidKeyStoreBridge {
  Future<bool> containsKey(String alias);
  Future<bool> generateKey({required String alias, required bool requireStrongBox});
  Future<Uint8List> encryptWithKey(String alias, Uint8List plaintext);
  Future<Uint8List> decryptWithKey(String alias, Uint8List ciphertext);
  Future<HardwareSecurityTier> queryHardwareTier();
}

/// Manages master cryptographic keys backed by Android KeyStore and StrongBox.
class HardwareKeyStoreProvider {
  final AndroidKeyStoreBridge bridge;
  final String masterKeyAlias;

  HardwareKeyMetadata? _keyMetadata;

  HardwareKeyStoreProvider({
    required this.bridge,
    this.masterKeyAlias = 'polyglot_vault_master_key',
  });

  HardwareKeyMetadata? get keyMetadata => _keyMetadata;
  bool get isReady => _keyMetadata != null;

  /// Initializes hardware key, preferring StrongBox HSM if supported.
  Future<HardwareKeyMetadata> initializeMasterKey() async {
    final tier = await bridge.queryHardwareTier();
    final preferStrongBox = tier == HardwareSecurityTier.strongBoxHsm;

    final keyExists = await bridge.containsKey(masterKeyAlias);
    if (!keyExists) {
      final generated = await bridge.generateKey(
        alias: masterKeyAlias,
        requireStrongBox: preferStrongBox,
      );
      if (!generated) {
        throw StateError('Failed to generate hardware key in KeyStore');
      }
    }

    _keyMetadata = HardwareKeyMetadata(
      keyAlias: masterKeyAlias,
      tier: tier,
      isStrongBoxBacked: preferStrongBox,
      createdAt: DateTime.now(),
    );

    return _keyMetadata!;
  }

  /// Encrypts master vault seed within hardware boundary.
  Future<Uint8List> sealMasterSeed(Uint8List seed) async {
    if (!isReady) await initializeMasterKey();
    return await bridge.encryptWithKey(masterKeyAlias, seed);
  }

  /// Decrypts master vault seed within hardware boundary.
  Future<Uint8List> unsealMasterSeed(Uint8List sealedSeed) async {
    if (!isReady) await initializeMasterKey();
    return await bridge.decryptWithKey(masterKeyAlias, sealedSeed);
  }
}
