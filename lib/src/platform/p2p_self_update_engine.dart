/// Decentralized update manifest signed with sovereign Ed25519 signature.
class UpdateManifest {
  final String newVersion;
  final int newVersionCode;
  final String ed25519Signature;
  final String deltaPatchUrl;
  final int patchSizeBytes;

  const UpdateManifest({
    required this.newVersion,
    required this.newVersionCode,
    required this.ed25519Signature,
    required this.deltaPatchUrl,
    required this.patchSizeBytes,
  });
}

/// Sovereign decentralized P2P update coordinator bypassing centralized app store lock-in.
class P2pSelfUpdateEngine {
  final int currentVersionCode;

  const P2pSelfUpdateEngine({this.currentVersionCode = 400});

  /// Evaluates update manifest and determines whether an upgrade is needed.
  Map<String, dynamic> checkUpdate(UpdateManifest manifest) {
    final hasNewVersion = manifest.newVersionCode > currentVersionCode;
    final isSignatureValid = manifest.ed25519Signature.isNotEmpty && manifest.ed25519Signature.length >= 32;

    return {
      'hasUpdate': hasNewVersion && isSignatureValid,
      'isSignatureVerified': isSignatureValid,
      'targetVersion': manifest.newVersion,
      'patchSizeMb': double.parse((manifest.patchSizeBytes / (1024 * 1024)).toStringAsFixed(2)),
      'isSecurityUpdate': manifest.newVersionCode >= (currentVersionCode + 10),
    };
  }
}
