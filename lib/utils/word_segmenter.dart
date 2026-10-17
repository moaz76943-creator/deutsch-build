import 'dart:collection';
import 'dart:math' as math;

/// Script classes relevant to tokenization behavior.
///
/// [whitespaceDelimited] is the safe default for scripts where punctuation and
/// whitespace are sufficient token boundaries. The remaining values represent
/// scriptio-continua families supported by the offline segmenter.
enum WordScript {
  whitespaceDelimited,
  han,
  japanese,
  thai,
  khmer,
  lao,
}

/// Lightweight, dependency-free tokenizer for both whitespace-delimited and
/// scriptio-continua text.
///
/// Continuous scripts are segmented with bounded longest-prefix matching when
/// a lexicon is supplied. If no lexicon entry matches at the current position,
/// the segmenter safely falls back to one Unicode unit and keeps progressing.
class WordSegmenter {
  WordSegmenter._();

  static const int maxInputCodePoints = 4096;
  static const int maxNGramLengthLimit = 16;
  static const int maxCandidateLimit = 4096;
  static const int defaultMaxNGramLength = 8;
  static const int defaultMaxCandidates = 512;

  /// Detects the dominant supported script in [text].
  ///
  /// Japanese Kana takes precedence over Han because Japanese commonly mixes
  /// Kanji with Hiragana/Katakana. Pure Han text resolves to [WordScript.han].
  /// Unknown and whitespace-delimited scripts resolve to
  /// [WordScript.whitespaceDelimited].
  static WordScript detectScript(String text) {
    _validateInput(text);

    var han = 0;
    var kana = 0;
    var thai = 0;
    var khmer = 0;
    var lao = 0;

    for (final rune in text.runes) {
      if (_isKana(rune)) {
        kana++;
      } else if (_isHan(rune)) {
        han++;
      } else if (_isThai(rune)) {
        thai++;
      } else if (_isKhmer(rune)) {
        khmer++;
      } else if (_isLao(rune)) {
        lao++;
      }
    }

    if (kana > 0) {
      return WordScript.japanese;
    }

    final counts = <WordScript, int>{
      WordScript.han: han,
      WordScript.thai: thai,
      WordScript.khmer: khmer,
      WordScript.lao: lao,
    };

    var bestScript = WordScript.whitespaceDelimited;
    var bestCount = 0;
    for (final entry in counts.entries) {
      if (entry.value > bestCount) {
        bestScript = entry.key;
        bestCount = entry.value;
      }
    }
    return bestScript;
  }

  /// Tokenizes [text] using whitespace/punctuation boundaries or bounded
  /// longest-prefix matching for non-segmented scripts.
  ///
  /// For continuous scripts, [lexicon] should contain complete surface forms.
  /// At each position the longest lexicon entry up to [maxNGramLength] wins.
  /// If no match exists, one Unicode unit is emitted as a safe fallback.
  static List<String> tokenize(
    String text, {
    Set<String>? lexicon,
    int maxNGramLength = defaultMaxNGramLength,
  }) {
    _validateInput(text);
    _validateMaxNGramLength(maxNGramLength);

    if (text.trim().isEmpty) {
      return const <String>[];
    }

    final script = detectScript(text);
    if (script == WordScript.whitespaceDelimited) {
      return _tokenizeDelimited(text);
    }

    return _tokenizeContinuous(
      text,
      lexicon: lexicon ?? const <String>{},
      maxNGramLength: maxNGramLength,
    );
  }

  /// Extracts bounded, longest-first n-gram candidates for dictionary lookup.
  ///
  /// The result is de-duplicated while preserving discovery order. Candidate
  /// generation is capped by [maxCandidates], [maxNGramLength], and
  /// [maxInputCodePoints], keeping execution and memory usage bounded.
  static List<String> extractCandidates(
    String text, {
    int maxNGramLength = defaultMaxNGramLength,
    int maxCandidates = defaultMaxCandidates,
  }) {
    _validateInput(text);
    _validateMaxNGramLength(maxNGramLength);
    if (maxCandidates < 1 || maxCandidates > maxCandidateLimit) {
      throw RangeError.range(
        maxCandidates,
        1,
        maxCandidateLimit,
        'maxCandidates',
      );
    }

    if (text.trim().isEmpty) {
      return const <String>[];
    }

    if (detectScript(text) == WordScript.whitespaceDelimited) {
      final tokens = _tokenizeDelimited(text);
      if (tokens.length <= maxCandidates) {
        return tokens;
      }
      return tokens.take(maxCandidates).toList(growable: false);
    }

    final candidates = LinkedHashSet<String>();
    for (final units in _continuousSpans(text)) {
      for (var start = 0; start < units.length; start++) {
        final remaining = units.length - start;
        final longest = math.min(maxNGramLength, remaining);

        for (var length = longest; length >= 1; length--) {
          candidates.add(units.sublist(start, start + length).join());
          if (candidates.length >= maxCandidates) {
            return List<String>.unmodifiable(candidates);
          }
        }
      }
    }

    return List<String>.unmodifiable(candidates);
  }

  static List<String> _tokenizeDelimited(String text) {
    final tokens = <String>[];
    final current = StringBuffer();

    void flush() {
      if (current.isEmpty) {
        return;
      }
      tokens.add(current.toString());
      current.clear();
    }

    for (final unit in _unicodeUnits(text)) {
      final rune = unit.runes.first;
      if (_isSeparatorRune(rune)) {
        flush();
      } else {
        current.write(unit);
      }
    }
    flush();

    return List<String>.unmodifiable(tokens);
  }

  static List<String> _tokenizeContinuous(
    String text, {
    required Set<String> lexicon,
    required int maxNGramLength,
  }) {
    final output = <String>[];

    for (final units in _continuousSpans(text)) {
      var index = 0;
      while (index < units.length) {
        final remaining = units.length - index;
        final longest = math.min(maxNGramLength, remaining);

        String? matched;
        var matchedLength = 0;

        if (lexicon.isNotEmpty) {
          for (var length = longest; length >= 1; length--) {
            final candidate = units.sublist(index, index + length).join();
            if (lexicon.contains(candidate)) {
              matched = candidate;
              matchedLength = length;
              break;
            }
          }
        }

        if (matched != null) {
          output.add(matched);
          index += matchedLength;
        } else {
          output.add(units[index]);
          index++;
        }
      }
    }

    return List<String>.unmodifiable(output);
  }

  static List<List<String>> _continuousSpans(String text) {
    final spans = <List<String>>[];
    var current = <String>[];

    void flush() {
      if (current.isEmpty) {
        return;
      }
      spans.add(current);
      current = <String>[];
    }

    for (final unit in _unicodeUnits(text)) {
      final rune = unit.runes.first;
      if (_isSeparatorRune(rune)) {
        flush();
      } else {
        current.add(unit);
      }
    }
    flush();

    return spans;
  }

  /// Produces Unicode units without depending on the external characters
  /// package. Combining marks used by Thai, Lao, Khmer, Japanese and common
  /// Unicode text are attached to the preceding scalar value.
  static List<String> _unicodeUnits(String text) {
    final units = <String>[];

    for (final rune in text.runes) {
      final scalar = String.fromCharCodes(<int>[rune]);
      if (_isCombiningRune(rune) && units.isNotEmpty) {
        units[units.length - 1] = units.last + scalar;
      } else {
        units.add(scalar);
      }
    }

    return units;
  }

  static void _validateInput(String text) {
    final length = text.runes.length;
    if (length > maxInputCodePoints) {
      throw RangeError.range(
        length,
        0,
        maxInputCodePoints,
        'text',
        'Input exceeds the bounded tokenizer limit',
      );
    }
  }

  static void _validateMaxNGramLength(int value) {
    if (value < 1 || value > maxNGramLengthLimit) {
      throw RangeError.range(
        value,
        1,
        maxNGramLengthLimit,
        'maxNGramLength',
      );
    }
  }

  static bool _isHan(int rune) {
    return _inRange(rune, 0x3400, 0x4DBF) ||
        _inRange(rune, 0x4E00, 0x9FFF) ||
        _inRange(rune, 0xF900, 0xFAFF) ||
        _inRange(rune, 0x20000, 0x2A6DF) ||
        _inRange(rune, 0x2A700, 0x2B73F) ||
        _inRange(rune, 0x2B740, 0x2B81F) ||
        _inRange(rune, 0x2B820, 0x2CEAF) ||
        _inRange(rune, 0x2CEB0, 0x2EBEF) ||
        _inRange(rune, 0x30000, 0x323AF);
  }

  static bool _isKana(int rune) {
    return _inRange(rune, 0x3040, 0x309F) ||
        _inRange(rune, 0x30A0, 0x30FF) ||
        _inRange(rune, 0x31F0, 0x31FF) ||
        _inRange(rune, 0xFF66, 0xFF9D);
  }

  static bool _isThai(int rune) => _inRange(rune, 0x0E00, 0x0E7F);

  static bool _isLao(int rune) => _inRange(rune, 0x0E80, 0x0EFF);

  static bool _isKhmer(int rune) {
    return _inRange(rune, 0x1780, 0x17FF) || _inRange(rune, 0x19E0, 0x19FF);
  }

  static bool _isCombiningRune(int rune) {
    return _inRange(rune, 0x0300, 0x036F) ||
        _inRange(rune, 0x1AB0, 0x1AFF) ||
        _inRange(rune, 0x1DC0, 0x1DFF) ||
        _inRange(rune, 0x20D0, 0x20FF) ||
        _inRange(rune, 0xFE20, 0xFE2F) ||
        _inRange(rune, 0xFE00, 0xFE0F) ||
        _inRange(rune, 0xE0100, 0xE01EF) ||
        rune == 0x3099 ||
        rune == 0x309A ||
        rune == 0x0E31 ||
        _inRange(rune, 0x0E34, 0x0E3A) ||
        _inRange(rune, 0x0E47, 0x0E4E) ||
        rune == 0x0EB1 ||
        _inRange(rune, 0x0EB4, 0x0EBC) ||
        _inRange(rune, 0x0EC8, 0x0ECD) ||
        _inRange(rune, 0x17B6, 0x17D3);
  }

  static bool _isSeparatorRune(int rune) {
    return rune <= 0x20 ||
        rune == 0x00A0 ||
        rune == 0x1680 ||
        _inRange(rune, 0x2000, 0x200A) ||
        rune == 0x2028 ||
        rune == 0x2029 ||
        rune == 0x202F ||
        rune == 0x205F ||
        rune == 0x3000 ||
        _inRange(rune, 0x0021, 0x002F) ||
        _inRange(rune, 0x003A, 0x0040) ||
        _inRange(rune, 0x005B, 0x0060) ||
        _inRange(rune, 0x007B, 0x007E) ||
        _inRange(rune, 0x200B, 0x206F) ||
        _inRange(rune, 0x2190, 0x2BFF) ||
        _inRange(rune, 0x3001, 0x303F) ||
        _inRange(rune, 0xFE10, 0xFE1F) ||
        _inRange(rune, 0xFE30, 0xFE6F) ||
        _inRange(rune, 0xFF01, 0xFF0F) ||
        _inRange(rune, 0xFF1A, 0xFF20) ||
        _inRange(rune, 0xFF3B, 0xFF40) ||
        _inRange(rune, 0xFF5B, 0xFF65) ||
        _inRange(rune, 0x1F000, 0x1FAFF);
  }

  static bool _inRange(int value, int start, int end) {
    return value >= start && value <= end;
  }
}
