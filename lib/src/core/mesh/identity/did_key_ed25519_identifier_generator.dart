/// Task 1541: Decentralized Identifier did:key generator based on Ed25519
class DidKeyGenerator {
  String generateDidKey(String base58Key) => 'did:key:z$base58Key';
}
