class DecentralizedRevocationAccumulator {
  final Set<String> revokedHashes = {};
  bool isValid(String certHash) => !revokedHashes.contains(certHash);
}
