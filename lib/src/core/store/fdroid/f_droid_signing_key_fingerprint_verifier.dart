class FDroidSigningKeyFingerprintVerifier {
  bool matchFingerprint(String keyFingerprint, String expected) =>
      keyFingerprint.toUpperCase() == expected.toUpperCase();
}
