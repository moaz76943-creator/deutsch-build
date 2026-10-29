class CognateRoot {
  final String rootId;
  final String protoForm;
  final String coreMeaning;
  final Map<String, String> languageLexemes;

  const CognateRoot({
    required this.rootId,
    required this.protoForm,
    required this.coreMeaning,
    required this.languageLexemes,
  });
}

class CoreRootsLexemesRegistry {
  final Map<String, CognateRoot> _roots = {};

  CoreRootsLexemesRegistry();

  static const List<CognateRoot> defaultCognates = [
    CognateRoot(
      rootId: 'root_brother',
      protoForm: '*bhrātēr',
      coreMeaning: 'Brother / الأخ',
      languageLexemes: {
        'de': 'Bruder',
        'en': 'brother',
        'ru': 'брат',
        'fa': 'برادر',
        'hi': 'भ्राता',
        'ga': 'bráthair',
      },
    ),
    CognateRoot(
      rootId: 'root_mother',
      protoForm: '*méh₂tēr',
      coreMeaning: 'Mother / الأم',
      languageLexemes: {
        'de': 'Mutter',
        'en': 'mother',
        'es': 'madre',
        'fr': 'mère',
        'ru': 'мать',
        'fa': 'مادر',
      },
    ),
    CognateRoot(
      rootId: 'root_write_semitic',
      protoForm: 'k-t-b',
      coreMeaning: 'Write / الكتابة',
      languageLexemes: {
        'ar': 'كتب',
        'mt': 'kiteb',
        'syc': 'ܟܬܒ',
      },
    ),
  ];

  void initialize({List<CognateRoot>? customRoots}) {
    _roots.clear();
    final source = customRoots ?? defaultCognates;
    for (final r in source) {
      _roots[r.rootId] = r;
    }
  }

  CognateRoot? findRootForWord(String langIso, String word) {
    final target = word.toLowerCase().trim();
    for (final r in _roots.values) {
      if (r.languageLexemes[langIso]?.toLowerCase() == target) {
        return r;
      }
    }
    return null;
  }

  int get rootsCount => _roots.length;
}
