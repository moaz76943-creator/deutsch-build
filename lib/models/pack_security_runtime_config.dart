final class PackSecurityRuntimeConfig {
  const PackSecurityRuntimeConfig({
    required this.manifestKeyId,
    required this.manifestPublicKeyBase64,
  });

  factory PackSecurityRuntimeConfig.fromEnvironment() =>
      const PackSecurityRuntimeConfig(
        manifestKeyId: String.fromEnvironment('PACK_MANIFEST_KEY_ID'),
        manifestPublicKeyBase64: String.fromEnvironment(
          'PACK_MANIFEST_PUBLIC_KEY_B64',
        ),
      );

  final String manifestKeyId;
  final String manifestPublicKeyBase64;

  bool get hasTrustedManifestKey =>
      manifestKeyId.trim().isNotEmpty &&
      manifestPublicKeyBase64.trim().isNotEmpty;
}
