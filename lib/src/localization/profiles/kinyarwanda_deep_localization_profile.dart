import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Kinyarwanda (Ikinyarwanda).
///
/// Central/East Bantu (Rwanda-Rundi) language spoken by 25M+ people in Rwanda,
/// Burundi, DRC, and Uganda. Features 16 noun classes with initial augment vowels
/// encoding definiteness, complex agglutinative verbal prefix/infix/suffix morphology,
/// tonal pitch registers, and omnidirectional cross-linguistic alignment.
@immutable
class KinyarwandaDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final int nounClassCount;
  final Map<String, String> augmentNounClassBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const KinyarwandaDeepLocalizationProfile({
    this.languageName = 'Kinyarwanda',
    this.autonym = 'Ikinyarwanda',
    this.iso6391 = 'rw',
    this.iso6392or3 = 'kin',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = true,
    this.hasGrammaticalGender = true, // 16 noun classes!
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Kinyarwanda alphabet)',
    this.nounClassCount = 16,
    this.augmentNounClassBridge = const {
      '16-Noun-Class Augment Definiteness': 'Kinyarwanda prefixes an augment vowel before the class prefix to express definiteness (u-mu-ntu = the person vs mu-ntu = a person). Directly anchors German der, die, das vs ein, eine, ein.',
      'Applicative and Causative Verbal Extensions': 'Verbal suffixes (-ish-, -er-) modify valency, mapping to German prefixes (be-, ver-, er-) and prepositional arguments.',
    },
    this.culturalIslamicLexicon = const {
      'muraho / salamu alaykum': 'Hallo / Begrüßung / Friede (Arabic: سلام عليكم)',
      'murakoze / murakoze cyane': 'Danke / Vielen Dank',
      'nyamuneka / ndabasaba': 'Bitte',
      'igitabo': 'Buch (Arabic: كتاب)',
      'ishuri / madrassa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'umwarimu / ustadh': 'Lehrer / Dozent (Arabic: معلم / أستاذ)',
      'ubumenyi / siyaansi': 'Wissen / Wissenschaft',
      'ubutabera': 'Gerechtigkeit',
      'gusenga / salat': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'inshuti': 'Freund',
      'amazi': 'Wasser',
      'umugati': 'Brot / Nahrung (Swahili loan: mkate)',
      'inzu': 'Haus / Heim',
      'umujyi': 'Stadt',
      'ibitaro': 'Krankenhaus',
      'farumasi': 'Apotheke',
      'umusigiti': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Kinyarwanda "Sh / sh" (ishuri, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Kinyarwanda "C / c" (/tʃ/) (cyane, Deutschland).',
      'z /ts/': 'Kinyarwanda "z" is /z/; German "z" is practiced as the compound sequence "t+s" (tsunami -> Zeit).',
      'ch /x/ (ach-Laut)': 'Mapped via velar/uvular fricative release contrasting with aspirated plosives.',
    },
    this.coreA1Vocabulary = const {
      'Muraho': 'Hallo / Guten Tag',
      'Mwaramutse': 'Guten Morgen',
      'Mwiriwe': 'Guten Tag / Guten Abend',
      'Murakoze cyane': 'Vielen Dank',
      'Nyamuneka': 'Bitte',
      'Yego': 'Ja',
      'Oya': 'Nein',
      'Nitwa ...': 'Mein Name ist ...',
      'Mukahe he?': 'Woher kommen Sie?',
      'Nkomoka muri ...': 'Ich komme aus ...',
      'Amazi': 'Wasser',
      'Umugati': 'Brot',
      'Ibitaro': 'Krankenhaus',
      'Farumasi': 'Apotheke',
      'Gari ya moshi': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'kinyarwanda': 'Muraho! Uvuga ikidage?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'kinyarwanda': 'Yego, ndimo ndiga ikidage ubu.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'kinyarwanda': 'Nyamuneka, farumasi yegereye hano iri he?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'kinyarwanda': 'Murakoze cyane ku bufasha bwanyu!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
