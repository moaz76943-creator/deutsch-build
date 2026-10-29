/// High-performance offline phonetic transliterator converting non-Latin scripts to Latin phonetics.
class UniversalPhoneticTransliterationEngine {
  const UniversalPhoneticTransliterationEngine();

  static const Map<String, String> _cyrillicMap = {
    'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ё': 'yo',
    'ж': 'zh', 'з': 'z', 'и': 'i', 'й': 'y', 'к': 'k', 'л': 'l', 'м': 'm',
    'н': 'n', 'о': 'o', 'п': 'p', 'р': 'r', 'с': 's', 'ت': 't', 'у': 'u',
    'ф': 'f', 'х': 'kh', 'ц': 'ts', 'ч': 'ch', 'ш': 'sh', 'щ': 'shch',
    'ъ': '', 'ы': 'y', 'ь': "'", 'э': 'e', 'ю': 'yu', 'я': 'ya',
  };

  static const Map<String, String> _greekMap = {
    'α': 'a', 'β': 'v', 'γ': 'g', 'δ': 'd', 'ε': 'e', 'ζ': 'z', 'η': 'i',
    'θ': 'th', 'ι': 'i', 'κ': 'k', 'λ': 'l', 'μ': 'm', 'ν': 'n', 'ξ': 'x',
    'ο': 'o', 'π': 'p', 'ρ': 'r', 'σ': 's', 'ς': 's', 'τ': 't', 'υ': 'y',
    'φ': 'f', 'χ': 'ch', 'ψ': 'ps', 'ω': 'o',
  };

  static const Map<String, String> _devanagariMap = {
    'अ': 'a', 'आ': 'aa', 'इ': 'i', 'ई': 'ee', 'उ': 'u', 'ऊ': 'oo',
    'क': 'k', 'ख': 'kh', 'ग': 'g', 'घ': 'gh', 'च': 'ch', 'ज': 'j',
    'त': 't', 'थ': 'th', 'द': 'd', 'ध': 'dh', 'न': 'n', 'प': 'p',
    'फ': 'ph', 'ब': 'b', 'भ': 'bh', 'म': 'm', 'य': 'y', 'र': 'r',
    'ल': 'l', 'व': 'v', 'स': 's', 'ह': 'h',
  };

  /// Transliterates input word to phonetic Latin equivalent.
  String transliterateToLatin(String input) {
    if (input.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      final lower = char.toLowerCase();

      if (_cyrillicMap.containsKey(lower)) {
        final mapped = _cyrillicMap[lower]!;
        buffer.write(char == lower ? mapped : mapped.toUpperCase());
      } else if (_greekMap.containsKey(lower)) {
        final mapped = _greekMap[lower]!;
        buffer.write(char == lower ? mapped : mapped.toUpperCase());
      } else if (_devanagariMap.containsKey(char)) {
        buffer.write(_devanagariMap[char]!);
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}
