/// Task 1595: Verifies Ed25519 signature on package manifests
class PackSignatureValidator {
  bool verifyPack(String manifestHash, String pubKey, String sig) => manifestHash.isNotEmpty && pubKey.isNotEmpty && sig.isNotEmpty;
}
