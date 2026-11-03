class InternationalPhoneticAlphabetIpaUniversalMatrix {
  final Map<String, String> ipaSymbols = {'ع': 'ʕ', 'ح': 'ħ', 'خ': 'x', 'ق': 'q', 'ç': 'tʃ', 'ö': 'ø'};
  String getIpa(String char) => ipaSymbols[char] ?? char;
}
