/// Offline, dependency-free romanization for supported writing systems.
///
/// This is a lightweight reading aid, not translation or phonetic IPA.
/// Unknown characters (including kanji) remain unchanged. Unsupported
/// script identifiers return null. Hindi retains inherent schwa and Arabic
/// follows a simplified ASCII Buckwalter-style mapping without guessing vowels.
class TransliterationEngine {
  TransliterationEngine._();

  static String? transliterateToLatin(String input, String scriptFamily) {
    switch (scriptFamily.trim().toLowerCase()) {
      case 'cyrillic':
      case 'russian':
      case 'ru':
        return _mapped(input, _russian);
      case 'ukrainian':
      case 'uk':
        return _mapped(input, _russian,
            overrides: _ukrainian, ukrainian: true);
      case 'bulgarian':
      case 'bg':
        return _mapped(input, _russian, overrides: _bulgarian);
      case 'greek':
      case 'el':
        return _romanizeGreek(input);
      case 'devanagari':
      case 'hindi':
      case 'hi':
        return _romanizeHindi(input);
      case 'japanese':
      case 'kana':
      case 'hiragana':
      case 'katakana':
      case 'ja':
        return _romanizeKana(input);
      case 'arabic':
      case 'ar':
        return _mapped(input, _arabic);
      default:
        return null;
    }
  }

  static bool _upper(int rune) {
    final c = String.fromCharCode(rune);
    return c == c.toUpperCase() && c != c.toLowerCase();
  }

  static String _caseAt(List<int> runes, int index, String latin) {
    if (!_upper(runes[index]) || latin.isEmpty) return latin;
    final before = index > 0 && _upper(runes[index - 1]);
    final after = index + 1 < runes.length && _upper(runes[index + 1]);
    return (before || after)
        ? latin.toUpperCase()
        : '${latin[0].toUpperCase()}${latin.substring(1)}';
  }

  static String _mapped(String input, Map<String, String> mapping, {
    Map<String, String> overrides = const <String, String>{},
    bool ukrainian = false,
  }) {
    final runes = input.runes.toList(growable: false);
    final output = StringBuffer();
    for (var i = 0; i < runes.length; i++) {
      final c = String.fromCharCode(runes[i]);
      final key = c.toLowerCase();
      String? latin = overrides[key] ?? mapping[key];
      if (ukrainian && key == 'ї' && i > 0 &&
          'аеєиіїоуюя'.contains(
              String.fromCharCode(runes[i - 1]).toLowerCase())) {
        latin = 'i';
      }
      output.write(latin == null ? c : _caseAt(runes, i, latin));
    }
    return output.toString();
  }

  static const Map<String, String> _russian = <String, String>{
    'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e',
    'ё': 'yo', 'ж': 'zh', 'з': 'z', 'и': 'i', 'й': 'y', 'к': 'k',
    'л': 'l', 'м': 'm', 'н': 'n', 'о': 'o', 'п': 'p', 'р': 'r',
    'с': 's', 'т': 't', 'у': 'u', 'ф': 'f', 'х': 'kh', 'ц': 'ts',
    'ч': 'ch', 'ш': 'sh', 'щ': 'shch', 'ъ': '', 'ы': 'y',
    'ь': '', 'э': 'e', 'ю': 'yu', 'я': 'ya',
  };

  static const Map<String, String> _ukrainian = <String, String>{
    'г': 'h', 'ґ': 'g', 'е': 'e', 'є': 'ye', 'и': 'y',
    'і': 'i', 'ї': 'yi', 'й': 'y',
  };

  static const Map<String, String> _bulgarian = <String, String>{
    'ъ': 'a', 'щ': 'sht', 'ь': '', 'й': 'y',
  };

  static const Map<String, String> _greek = <String, String>{
    'α': 'a', 'ά': 'a', 'β': 'v', 'γ': 'g', 'δ': 'd',
    'ε': 'e', 'έ': 'e', 'ζ': 'z', 'η': 'i', 'ή': 'i',
    'θ': 'th', 'ι': 'i', 'ί': 'i', 'ϊ': 'i', 'ΐ': 'i',
    'κ': 'k', 'λ': 'l', 'μ': 'm', 'ν': 'n', 'ξ': 'x',
    'ο': 'o', 'ό': 'o', 'π': 'p', 'ρ': 'r', 'σ': 's',
    'ς': 's', 'τ': 't', 'υ': 'y', 'ύ': 'y', 'ϋ': 'y',
    'ΰ': 'y', 'φ': 'f', 'χ': 'ch', 'ψ': 'ps', 'ω': 'o',
    'ώ': 'o',
  };

  static String _romanizeGreek(String input) {
    final runes = input.runes.toList(growable: false);
    final output = StringBuffer();
    for (var i = 0; i < runes.length; i++) {
      final c = String.fromCharCode(runes[i]);
      final lower = c.toLowerCase();
      if (i + 1 < runes.length) {
        final next = String.fromCharCode(runes[i + 1]).toLowerCase();
        if ('$lower$next' == 'ου' ||
            '$lower$next' == 'ού' ||
            '$lower$next' == 'οϋ') {
          output.write(_upper(runes[i])
              ? (_upper(runes[i + 1]) ? 'OU' : 'Ou')
              : 'ou');
          i++;
          continue;
        }
      }
      final latin = _greek[lower];
      output.write(latin == null ? c : _caseAt(runes, i, latin));
    }
    return output.toString();
  }

  static const Map<String, String> _hindiConsonants = <String, String>{
    'क': 'k', 'ख': 'kh', 'ग': 'g', 'घ': 'gh', 'ङ': 'ng',
    'च': 'ch', 'छ': 'chh', 'ज': 'j', 'झ': 'jh', 'ञ': 'ny',
    'ट': 't', 'ठ': 'th', 'ड': 'd', 'ढ': 'dh', 'ण': 'n',
    'त': 't', 'थ': 'th', 'द': 'd', 'ध': 'dh', 'न': 'n',
    'प': 'p', 'फ': 'ph', 'ब': 'b', 'भ': 'bh', 'म': 'm',
    'य': 'y', 'र': 'r', 'ल': 'l', 'व': 'v', 'श': 'sh',
    'ष': 'sh', 'स': 's', 'ह': 'h', 'ळ': 'l',
    'क़': 'q', 'ख़': 'kh', 'ग़': 'gh', 'ज़': 'z',
    'ड़': 'r', 'ढ़': 'rh', 'फ़': 'f', 'य़': 'y',
  };
  static const Map<String, String> _hindiVowels = <String, String>{
    'अ': 'a', 'आ': 'aa', 'इ': 'i', 'ई': 'ii', 'उ': 'u',
    'ऊ': 'uu', 'ऋ': 'ri', 'ॠ': 'rii', 'ऌ': 'li',
    'ए': 'e', 'ऐ': 'ai', 'ओ': 'o', 'औ': 'au',
    'ऑ': 'o', 'ऍ': 'e',
  };
  static const Map<String, String> _hindiMatras = <String, String>{
    'ा': 'aa', 'ि': 'i', 'ी': 'ii', 'ु': 'u', 'ू': 'uu',
    'ृ': 'ri', 'ॄ': 'rii', 'ॢ': 'li', 'े': 'e', 'ै': 'ai',
    'ो': 'o', 'ौ': 'au', 'ॅ': 'e', 'ॉ': 'o',
  };
  static const Map<String, String> _hindiMarks = <String, String>{
    'ं': 'n', 'ँ': 'n', 'ः': 'h', 'ऽ': "'", '।': '.', '॥': '..',
  };

  static String _romanizeHindi(String input) {
    final runes = input.runes.toList(growable: false);
    final output = StringBuffer();
    for (var i = 0; i < runes.length; i++) {
      final current = String.fromCharCode(runes[i]);
      final consonant = _hindiConsonants[current];
      if (consonant != null) {
        if (i + 1 < runes.length && runes[i + 1] == 0x093C) i++;
        if (i + 1 < runes.length) {
          final next = String.fromCharCode(runes[i + 1]);
          if (next == '्') {
            output.write(consonant);
            i++;
            continue;
          }
          final vowel = _hindiMatras[next];
          if (vowel != null) {
            output.write('$consonant$vowel');
            i++;
            continue;
          }
        }
        output.write('${consonant}a');
      } else if (current != '्' && current != '़') {
        output.write(_hindiVowels[current] ?? _hindiMarks[current] ?? current);
      }
    }
    return output.toString();
  }

  static const Map<String, String> _kana = <String, String>{
    'ぁ': 'a', 'あ': 'a', 'ぃ': 'i', 'い': 'i',
    'ぅ': 'u', 'う': 'u', 'ぇ': 'e', 'え': 'e',
    'ぉ': 'o', 'お': 'o',
    'か': 'ka', 'き': 'ki', 'く': 'ku', 'け': 'ke', 'こ': 'ko',
    'が': 'ga', 'ぎ': 'gi', 'ぐ': 'gu', 'げ': 'ge', 'ご': 'go',
    'さ': 'sa', 'し': 'shi', 'す': 'su', 'せ': 'se', 'そ': 'so',
    'ざ': 'za', 'じ': 'ji', 'ず': 'zu', 'ぜ': 'ze', 'ぞ': 'zo',
    'た': 'ta', 'ち': 'chi', 'つ': 'tsu', 'て': 'te', 'と': 'to',
    'だ': 'da', 'ぢ': 'ji', 'づ': 'zu', 'で': 'de', 'ど': 'do',
    'な': 'na', 'に': 'ni', 'ぬ': 'nu', 'ね': 'ne', 'の': 'no',
    'は': 'ha', 'ひ': 'hi', 'ふ': 'fu', 'へ': 'he', 'ほ': 'ho',
    'ば': 'ba', 'び': 'bi', 'ぶ': 'bu', 'べ': 'be', 'ぼ': 'bo',
    'ぱ': 'pa', 'ぴ': 'pi', 'ぷ': 'pu', 'ぺ': 'pe', 'ぽ': 'po',
    'ま': 'ma', 'み': 'mi', 'む': 'mu', 'め': 'me', 'も': 'mo',
    'ゃ': 'ya', 'や': 'ya', 'ゅ': 'yu', 'ゆ': 'yu',
    'ょ': 'yo', 'よ': 'yo',
    'ら': 'ra', 'り': 'ri', 'る': 'ru', 'れ': 're', 'ろ': 'ro',
    'ゎ': 'wa', 'わ': 'wa', 'ゐ': 'wi', 'ゑ': 'we', 'を': 'o',
    'ゔ': 'vu', 'ん': 'n',
  };
  static const Map<String, String> _kanaDigraph = <String, String>{
    'きゃ': 'kya', 'きゅ': 'kyu', 'きょ': 'kyo',
    'ぎゃ': 'gya', 'ぎゅ': 'gyu', 'ぎょ': 'gyo',
    'しゃ': 'sha', 'しゅ': 'shu', 'しょ': 'sho',
    'じゃ': 'ja', 'じゅ': 'ju', 'じょ': 'jo',
    'ちゃ': 'cha', 'ちゅ': 'chu', 'ちょ': 'cho',
    'ぢゃ': 'ja', 'ぢゅ': 'ju', 'ぢょ': 'jo',
    'にゃ': 'nya', 'にゅ': 'nyu', 'にょ': 'nyo',
    'ひゃ': 'hya', 'ひゅ': 'hyu', 'ひょ': 'hyo',
    'びゃ': 'bya', 'びゅ': 'byu', 'びょ': 'byo',
    'ぴゃ': 'pya', 'ぴゅ': 'pyu', 'ぴょ': 'pyo',
    'みゃ': 'mya', 'みゅ': 'myu', 'みょ': 'myo',
    'りゃ': 'rya', 'りゅ': 'ryu', 'りょ': 'ryo',
    'ふぁ': 'fa', 'ふぃ': 'fi', 'ふぇ': 'fe', 'ふぉ': 'fo',
    'てぃ': 'ti', 'でぃ': 'di', 'とぅ': 'tu', 'どぅ': 'du',
    'しぇ': 'she', 'じぇ': 'je', 'ちぇ': 'che',
    'ゔぁ': 'va', 'ゔぃ': 'vi', 'ゔぇ': 've', 'ゔぉ': 'vo',
  };

  static int _toHiragana(int rune) =>
      rune >= 0x30A1 && rune <= 0x30F6 ? rune - 0x60 : rune;

  static _KanaSyllable? _syllable(List<int> runes, int index) {
    if (index >= runes.length) return null;
    final first = String.fromCharCode(_toHiragana(runes[index]));
    if (index + 1 < runes.length) {
      final second = String.fromCharCode(_toHiragana(runes[index + 1]));
      final doubleKana = _kanaDigraph['$first$second'];
      if (doubleKana != null) return _KanaSyllable(doubleKana, 2);
    }
    final single = _kana[first];
    return single == null ? null : _KanaSyllable(single, 1);
  }

  static String _romanizeKana(String input) {
    final runes = input.runes.toList(growable: false);
    final tokens = <_KanaToken>[];
    for (var i = 0; i < runes.length; i++) {
      final code = _toHiragana(runes[i]);
      if (code == 0x3063) { // っ / ッ: geminated onset.
        final next = _syllable(runes, i + 1);
        if (next == null || next.text.isEmpty) {
          tokens.add(const _KanaToken('っ', false));
        } else {
          final onset = next.text.startsWith('ch') ||
                  next.text.startsWith('ts')
              ? 't'
              : next.text.substring(0, 1);
          tokens.add('aeiou'.contains(onset)
              ? const _KanaToken('っ', false)
              : _KanaToken(onset, true));
        }
        continue;
      }
      if (code == 0x3093) { // ん / ン: moraic nasal.
        final sound = _syllable(runes, i + 1)?.text ?? '';
        final nasal = sound.startsWith('b') || sound.startsWith('p') ||
                sound.startsWith('m')
            ? 'm'
            : sound.isNotEmpty && 'aeiouy'.contains(sound[0])
                ? "n'"
                : 'n';
        tokens.add(_KanaToken(nasal, true));
        continue;
      }
      if (runes[i] == 0x30FC) { // ー: long-vowel mark.
        tokens.add(const _KanaToken('ー', true));
        continue;
      }
      final syllable = _syllable(runes, i);
      if (syllable == null) {
        tokens.add(_KanaToken(String.fromCharCode(runes[i]), false));
      } else {
        tokens.add(_KanaToken(syllable.text, true));
        i += syllable.consumed - 1;
      }
    }

    final result = StringBuffer();
    for (var i = 0; i < tokens.length; i++) {
      final current = tokens[i];
      if (current.text == 'ー') {
        result.write('ー'); // Orphaned mark is preserved.
        continue;
      }
      if (current.kana && i + 1 < tokens.length && tokens[i + 1].kana) {
        final next = tokens[i + 1].text;
        final long = next == 'ー'
            ? _macron(current.text)
            : _macron(current.text, next: next);
        if (long != null) {
          result.write(long);
          i++;
          continue;
        }
      }
      result.write(current.text);
    }
    return result.toString();
  }

  static String? _macron(String syllable, {String? next}) {
    if (syllable.isEmpty) return null;
    final vowel = syllable.substring(syllable.length - 1);
    if (!'aeiou'.contains(vowel) ||
        (next != null && next != vowel && !(vowel == 'o' && next == 'u'))) {
      return null;
    }
    const signs = <String, String>{
      'a': 'ā', 'e': 'ē', 'i': 'ī', 'o': 'ō', 'u': 'ū',
    };
    return '${syllable.substring(0, syllable.length - 1)}${signs[vowel]}';
  }

  static const Map<String, String> _arabic = <String, String>{
    'ء': "'", 'آ': '|', 'أ': '>', 'ؤ': '&', 'إ': '<', 'ئ': '}',
    'ا': 'A', 'ب': 'b', 'ة': 'p', 'ت': 't', 'ث': 'v', 'ج': 'j',
    'ح': 'H', 'خ': 'x', 'د': 'd', 'ذ': '*', 'ر': 'r',
    'ز': 'z', 'س': 's', 'ش': r'$', 'ص': 'S', 'ض': 'D',
    'ط': 'T', 'ظ': 'Z', 'ع': 'E', 'غ': 'g', 'ف': 'f',
    'ق': 'q', 'ك': 'k', 'ل': 'l', 'م': 'm', 'ن': 'n',
    'ه': 'h', 'و': 'w', 'ى': 'Y', 'ي': 'y', 'ٱ': '{',
    'ً': 'F', 'ٌ': 'N', 'ٍ': 'K', 'َ': 'a', 'ُ': 'u',
    'ِ': 'i', 'ّ': '~', 'ْ': 'o', 'ـ': '',
  };
}

class _KanaSyllable {
  const _KanaSyllable(this.text, this.consumed);
  final String text;
  final int consumed;
}

class _KanaToken {
  const _KanaToken(this.text, this.kana);
  final String text;
  final bool kana;
}
