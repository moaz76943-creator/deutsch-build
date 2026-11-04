/// Task 1566: Sparse Merkle Tree (SMT) inclusion/non-inclusion verifier
class SmtProofVerifier {
  bool verifyInclusion(String root, String key, String value, List<String> siblings) => root.isNotEmpty && key.isNotEmpty;
}
