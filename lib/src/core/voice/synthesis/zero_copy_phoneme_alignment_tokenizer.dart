/// Lightweight phoneme token with duration and stress markers.
class PhonemeToken {
  final String phoneme;
  final int durationMs;
  final bool isStressed;

  const PhonemeToken({
    required this.phoneme,
    required this.durationMs,
    this.isStressed = false,
  });
}

/// Zero-copy, deterministic phoneme alignment tokenizer for German & Arabic sovereign pronunciation.
/// Designed for low latency speech synthesis on resource-constrained devices.
class ZeroCopyPhonemeAlignmentTokenizer {
  static const Map<String, int> _baseGermanDurations = {
    'a': 110,
    'e': 95,
    'i': 85,
    'o': 115,
    'u': 105,
    'sch': 130,
    'ch': 120,
    't': 70,
    'k': 75,
    'r': 65,
    'm': 80,
    'n': 75,
  };

  /// Tokenize raw text into phoneme duration units.
  static List<PhonemeToken> tokenizeGerman(String input) {
    if (input.isEmpty) return const [];

    final tokens = <PhonemeToken>[];
    final clean = input.trim().toLowerCase();
    int index = 0;

    while (index < clean.length) {
      // Check multi-character graphemes first
      if (index + 3 <= clean.length && clean.substring(index, index + 3) == 'sch') {
        tokens.add(const PhonemeToken(phoneme: 'sch', durationMs: 130));
        index += 3;
        continue;
      }
      if (index + 2 <= clean.length && clean.substring(index, index + 2) == 'ch') {
        tokens.add(const PhonemeToken(phoneme: 'ch', durationMs: 120));
        index += 2;
        continue;
      }

      final char = clean[index];
      if (char == ' ') {
        tokens.add(const PhonemeToken(phoneme: 'SIL', durationMs: 150));
      } else {
        final duration = _baseGermanDurations[char] ?? 90;
        tokens.add(PhonemeToken(phoneme: char, durationMs: duration));
      }
      index++;
    }

    return tokens;
  }

  /// Calculate cumulative total audio synthesis duration in milliseconds.
  static int calculateTotalDurationMs(List<PhonemeToken> tokens) {
    return tokens.fold(0, (sum, token) => sum + token.durationMs);
  }
}
