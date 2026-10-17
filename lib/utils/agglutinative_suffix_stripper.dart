/// Bounded reverse suffix analysis. Roots must be verified by a dictionary.
class SuffixAnalysis {
  const SuffixAnalysis(this.root, this.suffixes);
  final String root;

  /// Suffixes in removal order (outermost first).
  final List<String> suffixes;
}

typedef RootExists = Future<bool> Function(String root, String language);
typedef DictionarySearch = Future<List<Map<String, dynamic>>> Function(
    String query, String language);

class AgglutinativeSuffixStripper {
  const AgglutinativeSuffixStripper();
  static const maxCandidates = 48;
  static const _turkic = <String, String>{
    'lar': 'plural',
    'ler': 'plural',
    'dan': 'ablative',
    'den': 'ablative',
    'tan': 'ablative',
    'ten': 'ablative',
    'da': 'locative',
    'de': 'locative',
    'ta': 'locative',
    'te': 'locative',
    'ya': 'dative',
    'ye': 'dative',
    'a': 'dative',
    'e': 'dative',
    'yı': 'accusative',
    'yi': 'accusative',
    'yu': 'accusative',
    'yü': 'accusative',
    'ı': 'accusative',
    'i': 'accusative',
    'u': 'accusative',
    'ü': 'accusative',
    'nın': 'genitive',
    'nin': 'genitive',
    'nun': 'genitive',
    'nün': 'genitive',
    'ın': 'genitive',
    'in': 'genitive',
    'un': 'genitive',
    'ün': 'genitive',
  };
  static const _finnish = <String, String>{
    'ssa': 'inessive',
    'ssä': 'inessive',
    'sta': 'elative',
    'stä': 'elative',
    'lla': 'adessive',
    'llä': 'adessive',
    'lta': 'ablative',
    'ltä': 'ablative',
    'lle': 'allative',
    'ksi': 'translative',
    'na': 'essive',
    'nä': 'essive',
    'n': 'genitive',
    't': 'plural',
  };
  static const _hungarian = <String, String>{
    'ban': 'inessive',
    'ben': 'inessive',
    'nak': 'dative',
    'nek': 'dative',
    'ból': 'elative',
    'ből': 'elative',
    'hoz': 'allative',
    'hez': 'allative',
    'höz': 'allative',
    'ak': 'plural',
    'ok': 'plural',
    'ek': 'plural',
    'ök': 'plural',
  };

  List<SuffixAnalysis> decompose(
    String input, {
    required String languageCode,
    int depth = 3,
  }) {
    if (depth < 1 || depth > 3) throw RangeError.range(depth, 1, 3);
    final lang = languageCode.trim().toLowerCase().split('-').first;
    final rules = <String, String>{
      if (lang == 'tr' || lang == 'az') ..._turkic,
      if (lang == 'fi') ..._finnish,
      if (lang == 'hu') ..._hungarian,
    };
    final word = input.trim().toLowerCase();
    if (rules.isEmpty ||
        word.runes.length < 4 ||
        word.runes.length > 96 ||
        word.contains(RegExp(r'[\s\d]'))) {
      return const <SuffixAnalysis>[];
    }
    final suffixes = rules.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    var active = <SuffixAnalysis>[SuffixAnalysis(word, const [])];
    final found = <SuffixAnalysis>[];
    final seen = <String>{word};
    for (var level = 0; level < depth; level++) {
      final next = <SuffixAnalysis>[];
      for (final item in active) {
        for (final suffix in suffixes) {
          if (!item.root.endsWith(suffix)) continue;
          final stem = item.root.substring(0, item.root.length - suffix.length);
          if (stem.runes.length < 2 ||
              seen.contains(stem) ||
              !_valid(lang, stem, suffix, rules[suffix]!)) {
            continue;
          }
          seen.add(stem);
          final candidate = SuffixAnalysis(
              stem, List<String>.unmodifiable([...item.suffixes, suffix]));
          found.add(candidate);
          next.add(candidate);
          if (found.length == maxCandidates) break;
        }
        if (found.length == maxCandidates) break;
      }
      if (next.isEmpty || found.length == maxCandidates) break;
      active = next;
    }
    return List<SuffixAnalysis>.unmodifiable(found);
  }

  Future<SuffixAnalysis?> resolveRoot(
    String input, {
    required String languageCode,
    required RootExists exists,
  }) async {
    final lang = languageCode.trim().toLowerCase().split('-').first;
    for (final item in decompose(input, languageCode: lang)) {
      if (await exists(item.root, lang)) return item;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> searchWithSuffixFallback(
    String input, {
    required String languageCode,
    required DictionarySearch search,
  }) async {
    final lang = languageCode.trim().toLowerCase().split('-').first;
    final raw = await search(input, lang);
    if (raw.isNotEmpty) return raw;
    for (final item in decompose(input, languageCode: lang)) {
      final rows = await search(item.root, lang);
      if (rows.isNotEmpty) return rows;
    }
    return raw;
  }

  static String? _lastVowel(String s, String chars) {
    for (var i = s.length - 1; i >= 0; i--) {
      if (chars.contains(s[i])) return s[i];
    }
    return null;
  }

  static bool _valid(String lang, String stem, String suffix, String kind) {
    if (lang == 'tr' || lang == 'az') {
      final v = _lastVowel(stem, 'aeıioöuü');
      if (v == null) return false;
      final two = 'aıou'.contains(v) ? 'a' : 'e';
      final four = switch (v) {
        'a' || 'ı' => 'ı',
        'e' || 'i' => 'i',
        'o' || 'u' => 'u',
        _ => 'ü',
      };
      final last = stem[stem.length - 1];
      final hasBuffer = 'aeıioöuü'.contains(last);
      switch (kind) {
        case 'plural':
          return suffix == 'l${two}r';
        case 'locative':
        case 'ablative':
          return suffix ==
              ('fstkçşhp'.contains(last) ? 't' : 'd') +
                  two +
                  (kind == 'ablative' ? 'n' : '');
        case 'dative':
          return suffix == (hasBuffer ? 'y' : '') + two;
        case 'accusative':
          return suffix == (hasBuffer ? 'y' : '') + four;
        case 'genitive':
          return suffix == '${hasBuffer ? 'n' : ''}${four}n';
      }
      return false;
    }
    if (lang == 'fi') {
      if (suffix.endsWith('a') || suffix.endsWith('ä')) {
        final v = _lastVowel(stem, 'aouäöyei');
        if (v == null) return false;
        return suffix.endsWith('aou'.contains(v) ? 'a' : 'ä');
      }
      return true;
    }
    if (lang == 'hu') {
      final v = _lastVowel(stem, 'aáeéiíoóöőuúüű');
      if (v == null) return false;
      final front = 'eéiíöőüű'.contains(v);
      if (kind == 'plural') {
        return front
            ? ['ek', 'ök'].contains(suffix)
            : ['ak', 'ok'].contains(suffix);
      }
      if (kind == 'allative') {
        return suffix == (front ? ('öőüű'.contains(v) ? 'höz' : 'hez') : 'hoz');
      }
      if (kind == 'elative') return suffix == (front ? 'ből' : 'ból');
      return suffix ==
          (front
              ? (kind == 'inessive' ? 'ben' : 'nek')
              : (kind == 'inessive' ? 'ban' : 'nak'));
    }
    return false;
  }
}
