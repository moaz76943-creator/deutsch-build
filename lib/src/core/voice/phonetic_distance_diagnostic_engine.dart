class PhoneticDistanceDiagnosticEngine {
  const PhoneticDistanceDiagnosticEngine();
  double calculateIpaDistance(String ipa1, String ipa2) => ipa1 == ipa2 ? 0.0 : 0.5;
}
