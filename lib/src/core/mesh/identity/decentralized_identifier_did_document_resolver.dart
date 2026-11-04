/// Task 1552: W3C DID Document resolver mapping did:key to descriptors
class DidDocumentResolver {
  Map<String, dynamic> resolveDid(String did) => {'id': did, 'verificationMethod': [{'id': '$did#key-1', 'type': 'Ed25519VerificationKey2020'}]};
}
