import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Oromo (Afaan Oromoo).
///
/// Cushitic Afroasiatic language spoken by 40M+ people in Ethiopia and Kenya.
/// Features Qubee Latin script, strict SOV sentence structure (verb-final mirror),
/// agglutinative 7-case suffix morphology, vowel length quantity (short vs long vowels),
/// and comprehensive omnidirectional bridges across Semitic, Cushitic, and European languages.
@immutable
class OromoDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final List<String> qubeeSpecialGraphemes;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const OromoDeepLocalizationProfile({
    this.languageName = 'Oromo',
    this.autonym = 'Afaan Oromoo',
    this.iso6391 = 'om',
    this.iso6392or3 = 'orm',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.sov,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = false,
    this.hasGrammaticalGender = true, // Korma (masculine) & Dhalaa (feminine)
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Qubee Afaan Oromoo)',
    this.qubeeSpecialGraphemes = const ['ch', 'dh', 'ny', 'ph', 'sh', 'ts'],
    this.caseSystemAlignment = const {
      '1. Absolutiv (Base / Akkusativ)': 'Unmarked direct object form (namicha). Maps to German Akkusativ (den Mann).',
      '2. Nominativ (-ni / -ti / lengthening)': 'Subject marker in SOV sentence (namichi ni dhufa). Directly maps to German Nominativ (der Mann kommt).',
      '3. Genitiv (-aa / -ii / lengthening)': 'Possessive marker (kitaaba barsiisaa). Directly maps to German Genitiv (das Buch des Lehrers).',
      '4. Dativ (-f / -dhaaf / -tti)': 'Recipient or purposive suffix (barsiisaadhaaf). Directly maps to German Dativ (dem Lehrer).',
      '5. Instrumentalis (-n / -tiin)': 'Means or accompaniment (konkolaataadhaan). Maps to German Dativ with preposition "mit".',
      '6. Lokativ (-tti / -rra)': 'Location on or at (magaalatti). Maps to German Dativ with static prepositions "in" and "an".',
      '7. Ablativ (-rraa / -biraa)': 'Separation or source out of (Finfinneerraa). Maps to German Dativ with prepositions "aus" and "von".',
    },
    this.culturalIslamicLexicon = const {
      'akkam / nagaa / salaam': 'Hallo / Friede / Begrüßung (Arabic: سلام)',
      'galatoomi / baay\'ee galatoomi': 'Danke / Vielen Dank',
      'mee / maaloo': 'Bitte',
      'kitaaba': 'Buch (Arabic: كتاب)',
      'mana barumsaa / madrasaa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'barsiisaa': 'Lehrer / Dozent',
      'beekumsa / saayinsii': 'Wissen / Wissenschaft',
      'haqaa / murtii qajeelaa': 'Gerechtigkeit',
      'sagada / salaata': 'Gebet / Salāt (Arabic: صلاة)',
      'halaala': 'Erlaubt / Halal (Arabic: حلال)',
      'hiriyaa / jaallee': 'Freund',
      'bishaan': 'Wasser',
      'daabboo': 'Brot / Nahrung',
      'mana': 'Haus / Heim',
      'magaalaa': 'Stadt',
      'hospitaala / mana yaalaa': 'Krankenhaus',
      'mana qorichaa': 'Apotheke',
      'masjiida': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Qubee "Sh / sh" (shanan, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Qubee "Ch / ch" (chaaltuu, Deutschland).',
      'z /ts/': 'Direct match to Qubee "Ts / ts" (tsunami, tsanbaqoo -> Zeit).',
      'Vowel Length Quantity': 'Qubee long vowels (aa, ee, ii, oo, uu) provide native phonetic muscle memory for German vowel quantity contrasts (Bann vs Bahn, Stadt vs Staat).',
      'SOV Subordinate Mirror': 'Oromo natively places verbs at the clause end, providing effortless intuition for German subordinate clauses (weil ich Deutsch lerne).',
    },
    this.coreA1Vocabulary = const {
      'Akkam / Nagaa': 'Hallo / Guten Tag',
      'Akkam bulte': 'Guten Morgen',
      'Akkam oolte': 'Guten Tag',
      'Akkam galte': 'Guten Abend',
      'Baay\'ee galatoomi': 'Vielen Dank',
      'Maaloo': 'Bitte',
      'Eeyyee': 'Ja',
      'Lakki': 'Nein',
      'Maqaan koo ... dha': 'Mein Name ist ...',
      'Eessaa dhufte?': 'Woher kommen Sie?',
      'Ani ...-rran dhufe': 'Ich komme aus ...',
      'Bishaan': 'Wasser',
      'Daabboo': 'Brot',
      'Hospitaala': 'Krankenhaus',
      'Mana qorichaa': 'Apotheke',
      'Buufata baaburaa': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'oromo': 'Akkam! Afaan Jarmanii ni beektaa?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'oromo': 'Eeyyee, ani amma afaan Jarmanii barachaan jira.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'oromo': 'Mee natti himi, manni qorichaa inni dhihoo eessa jira?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'oromo': 'Gargaarsa keessaniif baay\'ee galatoomaa!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates an Oromo case into its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
