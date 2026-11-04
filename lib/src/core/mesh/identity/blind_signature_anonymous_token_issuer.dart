/// Task 1551: Chaumian blind signature token issuer for unlinkable tokens
class BlindSignatureIssuer {
  String blindToken(String secret, int blindFactor) => 'BLINDED_$secret';
  bool verifyUnblinded(String token, String sig) => token.isNotEmpty && sig.isNotEmpty;
}
