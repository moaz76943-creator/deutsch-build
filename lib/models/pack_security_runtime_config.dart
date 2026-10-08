final class PackSecurityRuntimeConfig {
  const PackSecurityRuntimeConfig({
    required this.manifestKeyId,
    required this.manifestPublicKeyBase64,
  });

  factory PackSecurityRuntimeConfig.fromEnvironment() =>
      const PackSecurityRuntimeConfig(
        manifestKeyId: String.fromEnvironment(
          'PACK_MANIFEST_KEY_ID',
          defaultValue: 'de-pack-v2',
        ),
        manifestPublicKeyBase64: String.fromEnvironment(
          'PACK_MANIFEST_PUBLIC_KEY_B64',
          defaultValue: 'RH4nVDKTvu+EQG90clQ4/Aar51eyfQa88HYFckkgerI=',
        ),
      );

  final String manifestKeyId;
  final String manifestPublicKeyBase64;

  bool get hasTrustedManifestKey =>
      manifestKeyId.trim().isNotEmpty &&
      manifestPublicKeyBase64.trim().isNotEmpty;
}
