/// Task 1543: W3C Verifiable Credentials signer for CEFR badges
class VerifiableCredentialSigner {
  String signCredential(String did, String claim, String sig) => '{"issuer":"$did","claim":"$claim","proof":"$sig"}';
}
