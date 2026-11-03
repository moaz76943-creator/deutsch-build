class SecurePassphraseBip39SeedPhraseVault {
  final int wordCount = 12;
  bool validateMnemonic(List<String> words) => words.length == 12;
}
