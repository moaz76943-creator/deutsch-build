class ReproducibleBuildBitForBitVerifier {
  bool verifyHashes(String localApkSha256, String upstreamSha256) =>
      localApkSha256.toLowerCase() == upstreamSha256.toLowerCase();
}
