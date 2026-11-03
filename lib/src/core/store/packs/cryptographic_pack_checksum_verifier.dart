class CryptographicPackChecksumVerifier {
  const CryptographicPackChecksumVerifier();
  bool verifySha256(String calculatedHash, String expectedHash) =>
      calculatedHash.trim().toLowerCase() == expectedHash.trim().toLowerCase();
}
