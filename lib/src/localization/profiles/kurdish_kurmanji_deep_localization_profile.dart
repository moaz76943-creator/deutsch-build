import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Kurdish Kurmanji (Kurmancî / Kurdî).
///
/// Indo-European -> Indo-Iranian -> Northwestern Iranian language spoken by 20M+ people.
/// Features Latin Hawar alphabet (Ç, Ê, Î, Ş, Û), split ergativity in past tenses,
/// distinct grammatical gender (masculine/feminine matching German Der/Die),
/// two primary cases (Direct / Oblique) and Izafe construct state.
@immutable
class KurdishKurmanjiDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasSplitErgativity;
  final bool hasGrammaticalGender;
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const KurdishKurmanjiDeepLocalizationProfile({
    this.languageName = 'Kurdish Kurmanji',
    this.autonym = 'Kurdî (Kurmancî)',
    this.iso6391 = 'ku',
    this.iso6392 = 'kmr',
    this.languageFamily = 'Indo-European',
    this.branch = 'Northwestern Iranian',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Hawar alphabet)',
    this.specialCharacters = const ['Ç', 'ç', 'Ê', 'ê', 'Î', 'î', 'Ş', 'ş', 'Û', 'û'],
    this.hasSplitErgativity = true,
    this.hasGrammaticalGender = true, // Nêr (masculine) & Mê (feminine)
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'Rewşa xwerû (Direct Case)': 'Subject in present tense (Ez diçim dibistanê). Mapped to German Nominativ (ich gehe zur Schule).',
      'Rewşa tewandî (Oblique Case)': 'Objects and prepositional complements (mêr -> mêrî; jin -> jinê). Directly maps to German Akkusativ & Dativ.',
      'Rewşa bangkirinê (Vocative Case)': 'Used in direct address (Lawiko! Keçikê!).',
      'Izafe Construct State': 'Connective vowels (-ê for masc., -a for fem., -ên for plural). Direct bridge to German Genitiv relationships (mala bavê min = das Haus meines Vaters).',
    },
    this.culturalIslamicLexicon = const {
      'silav': 'Friede / Begrüßung (Arabic: سلام)',
      'spas': 'Danke / Dankbarkeit',
      'ji kerema xwe': 'Bitte / Aus Ihrer Güte',
      'pirtûk': 'Buch',
      'dibistan': 'Schule',
      'mamoste': 'Lehrer / Meister',
      'zanist': 'Wissenschaft',
      'edalet': 'Gerechtigkeit (Arabic: عدالة)',
      'nimêj': 'Gebet / Salāt (Persian: نماز)',
      'rojî': 'Fasten / Ramadan',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'xêr': 'Güte / Segen (Arabic: خير)',
      'mal': 'Haus / Familie',
      'av': 'Wasser',
      'nan': 'Brot',
      'bajar': 'Stadt',
      'nexweşxane': 'Krankenhaus',
      'dermanxane': 'Apotheke',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Kurmanji "Ş / ş" (e.g., şev, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Kurmanji "Ç / ç" (e.g., çav, Deutschland).',
      'ch /x/ (ach-Laut)': 'Direct 1:1 match to Kurmanji "X / x" (e.g., xanî, Bach, Nacht).',
      'w /v/ vs v /f/': 'Kurmanji distinguishes "V" /v/ and "W" /w/. German "w" sounds like Kurmanji "V" (Wasser -> Vaser).',
      'ö /ø/ & ü /y/': 'Targeted front-rounding drills; Kurmanji "Û / û" serves as baseline for high-back to high-front lip rounding.',
      'Grammatical Gender Transfer': 'Kurmanji learners already understand noun gender (nêr/mê), facilitating acquisition of German der/die/das.',
    },
    this.coreA1Vocabulary = const {
      'Silav': 'Hallo / Guten Tag',
      'Beyanî baş': 'Guten Morgen',
      'Rojbaş': 'Guten Tag',
      'Êvar baş': 'Guten Abend',
      'Gelek spas': 'Vielen Dank',
      'Ji kerema xwe': 'Bitte',
      'Erê': 'Ja',
      'Na': 'Nein',
      'Navê min ... e': 'Mein Name ist ...',
      'Hûn ji ku derê ne?': 'Woher kommen Sie?',
      'Ez ji ... me': 'Ich komme aus ...',
      'Av': 'Wasser',
      'Nan': 'Brot',
      'Nexweşxane': 'Krankenhaus',
      'Dermanxane': 'Apotheke',
      'Stasyona trênê': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'kurdish': 'Silav! Hûn bi almanî dizanin?',
        'german': 'Guten Tag! Können Sie Deutsch?',
        'arabic': 'مرحباً! هل تعرف الألمانية؟',
      },
      {
        'kurdish': 'Erê, ez niha zimanê almanî hîn dibim.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'kurdish': 'Ji kerema xwe, dermanxaneya herî nêzîk li ku ye?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'kurdish': 'Gelek spas ji bo alîkariya we!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Validates availability of Hawar Latin graphemes.
  bool hasHawarLetter(String letter) {
    return specialCharacters.contains(letter);
  }

  /// Maps case alignment string to query.
  String? getCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
