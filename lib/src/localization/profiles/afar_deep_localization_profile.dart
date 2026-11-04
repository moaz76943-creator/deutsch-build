import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Afar (Qafár af).
///
/// Lowland East Cushitic language spoken by 2.5M+ people in Djibouti, Eritrea,
/// and Ethiopia. Characterized by Qafar Feera Latin script with native pharyngeal
/// phonemes matching Arabic (c = ع, x = ح), strict SOV sentence structure (verb-final),
/// pitch-accent nominal case marking, and 100% Islamic cultural heritage.
@immutable
class AfarDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
  @override
  final String languageName;
  @override
  final String autonym;
  @override
  final String iso6391;
  @override
  final String iso6392or3;
  @override
  final TypologicalClassification typology;
  @override
  final CanonicalWordOrder primaryWordOrder;
  @override
  final GrammaticalAlignment alignment;
  @override
  final bool hasTones;
  @override
  final bool hasGrammaticalGender;

  final String writingDirection;
  final String primaryScript;
  final List<String> pharyngealSpecialGraphemes;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const AfarDeepLocalizationProfile({
    this.languageName = 'Afar',
    this.autonym = 'Qafár af',
    this.iso6391 = 'aa',
    this.iso6392or3 = 'aar',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.sov,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = true, // Tonal pitch accent encoding case
    this.hasGrammaticalGender = true, // Masculine & Feminine
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Qafar Feera)',
    this.pharyngealSpecialGraphemes = const ['c (/ʕ/ Arabic ع)', 'x (/ħ/ Arabic ح)', 'q (/ɖ/ retroflex d)'],
    this.caseSystemAlignment = const {
      '1. Absolutiv (Base / Akkusativ)': 'Unmarked base form (numu). Directly maps to German Akkusativ (den Mann).',
      '2. Nominativ (Subject - accent shift / -i)': 'Accent shifts to penultimate syllable or suffix -i (númi). Maps to German Nominativ (der Mann).',
      '3. Genitiv (Possessive - accent shift)': 'Accent shift on governing noun (numí kitába). Maps to German Genitiv (des Mannes Buch).',
      '4. Dativ / Benefactive (-h / -y)': 'Suffix -h or -y (numuh). Directly maps to German Dativ (dem Mann).',
      '5. Lokativ / Instrumental (-t / -l)': 'Location or means (magaalat). Maps to German Dativ with prepositions "in", "an", "mit".',
    },
    this.culturalIslamicLexicon = const {
      'mahaba / salaam alaykum': 'Hallo / Begrüßung / Friede (Arabic: سلام عليكم)',
      'gaddali / faatima gaddali': 'Danke / Vielen Dank',
      'kobox / mee': 'Bitte',
      'kitaaba': 'Buch (Arabic: كتاب)',
      'madrasa / skool': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'barisaan / barseeni': 'Lehrer / Dozent',
      'ilim / yaalo': 'Wissen / Wissenschaft (Arabic: علم)',
      'caddalet': 'Gerechtigkeit (Arabic: عدالة)',
      'salat': 'Gebet / Salāt (Arabic: صلاة)',
      'xalaal': 'Erlaubt / Halal (Arabic: حلال)',
      'kattaata / kataysi': 'Freund',
      'lee': 'Wasser',
      'gambo': 'Brot / Nahrung',
      'qari': 'Haus / Heim',
      'magaala': 'Stadt',
      'ispitaal': 'Krankenhaus',
      'daawa qari': 'Apotheke',
      'masiigida': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Afar "Sh / sh" (shara, Schule, schön).',
      'ch /x/ (ach-Laut)': 'Mapped via voiceless velar/uvular friction in regional variants (Bach, Nacht).',
      'z /ts/': 'German "z" is an affricate /ts/, practiced as compound "t+s" (tsunami -> Zeit).',
      'Pharyngeal Advantage': 'Afar learners natively articulate Arabic pharyngeals (c = ع, x = ح), giving them exceptional vocal agility for all Semitic and Afroasiatic phonetic bridges.',
      'SOV Subordinate Mirror': 'Afar natively places verbs at the end of clauses, making German subordinate clause verb-final placement (weil ich Deutsch lerne) second nature!',
    },
    this.coreA1Vocabulary = const {
      'Mahaba / Salaam alaykum': 'Hallo / Guten Tag',
      'Saaku meqe': 'Guten Morgen',
      'Carra meqe': 'Guten Tag',
      'Kudha meqe': 'Guten Abend',
      'Gaddali': 'Vielen Dank',
      'Mee': 'Bitte',
      'Yeey': 'Ja',
      'Maleey': 'Nein',
      'Migaq ... kinni': 'Mein Name ist ...',
      'Ankettuk temeete?': 'Woher kommen Sie?',
      'Anu ...-k emeete': 'Ich komme aus ...',
      'Lee': 'Wasser',
      'Gambo': 'Brot',
      'Ispitaal': 'Krankenhaus',
      'Daawa qari': 'Apotheke',
      'Baabur gari': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'afar': 'Mahaba! German af yaabtaah?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'afar': 'Yeey, anu ah German af baritaanam faxa.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'afar': 'Mee iyyi, gabbata daawa qari ankette yaniih?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'afar': 'Ku qokoluh mangom gaddali!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates an Afar case structure into its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
