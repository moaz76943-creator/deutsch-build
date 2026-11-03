class PackTamperSafetyInterceptor {
  bool isSignatureValid(String signature, String pubKey) => signature.isNotEmpty && pubKey.isNotEmpty;
}
