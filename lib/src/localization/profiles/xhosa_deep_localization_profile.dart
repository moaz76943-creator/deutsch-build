import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Xhosa (isiXhosa).
///
/// Southern Bantu (Nguni) language spoken by 20M+ people in South Africa and Zimbabwe.
/// Famed for 15 noun classes (genders) with prefixal concord, rich Khoisan-derived
/// click consonants (c, x, q with aspirated and nasalized series), SVO word order,
/// and omnidirectional cross-lingual transfer across African and European languages.
@immutable
class XhosaDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final List<String> clickConsonants;
  final Map<String, String> nounClassConcordBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const XhosaDeepLocalizationProfile({
    this.languageName = 'Xhosa',
    this.autonym = 'isiXhosa',
    this.iso6391 = 'xh',
    this.iso6392or3 = 'xho',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = true,
    this.hasGrammaticalGender = true, // 15 noun classes/genders!
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Xhosa alphabet)',
    this.nounClassCount = 15,
    this.clickConsonants = const ['c (Dental click /ǀ/)', 'x (Alveolar-lateral click /ǁ/)', 'q (Postalveolar click /ǃ/)'],
    this.nounClassConcordBridge = const {
      '15-Noun-Class Concord': 'isiXhosa classifies nouns into 15 prefixal classes (um-/aba- humans, ili-/ama- natural pairs, isi-/izi- languages/objects). Operating 15 noun classes natively allows learners to master German\'s 3 genders (der, die, das) with zero conceptual friction.',
      'Locative Prefixation (e-...-eni)': 'Xhosa locative circumposition e-khaya-eni -> ekhaya (at home). Directly mirrors German static prepositions with Dativ (zu Hause, in der Stadt).',
    },
    this.culturalIslamicLexicon = const {
      'molo / molweni / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'enkosi / enkosi kakhulu': 'Danke / Vielen Dank',
      'nceda / ndiyacela': 'Bitte / Hilf mir',
      'incwadi': 'Buch',
      'isikolo / imadrasa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'utitshala / umfundisi': 'Lehrer / Dozent',
      'ulwazi / inzululwazi': 'Wissen / Wissenschaft',
      'ubulungisa': 'Gerechtigkeit',
      'umthandazo / isalat': 'Gebet / Salāt (Arabic: صلاة)',
      'i-halal': 'Erlaubt / Halal (Arabic: حلال)',
      'umhlobo': 'Freund',
      'amanzi': 'Wasser',
      'isonka': 'Brot / Nahrung',
      'indlu / ikhaya': 'Haus / Heim',
      'isixeko / idolophu': 'Stadt',
      'isibhedlele': 'Krankenhaus',
      'ikhemesti': 'Apotheke',
      'imosque / imasjid': 'Moschee (Arabic: جامع / مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Xhosa "Sh / sh" (ishumi, ishishini, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Xhosa "Tsh / tsh" (tshata, Deutschland).',
      'z /ts/': 'Xhosa "z" is voiced /z/; German "z" is practiced as the compound sequence "t+s" (tsunami -> Zeit).',
      'ch /x/ (ach-Laut)': 'Direct match to Xhosa velar/uvular fricative in regional variants (Bach, Nacht).',
    },
    this.coreA1Vocabulary = const {
      'Molo / Molweni': 'Hallo / Guten Tag',
      'Gusasa elihle': 'Guten Morgen',
      'Imini emnandi': 'Guten Tag',
      'Ubusuku obuhle': 'Guten Abend',
      'Enkosi kakhulu': 'Vielen Dank',
      'Nceda': 'Bitte',
      'Ewe': 'Ja',
      'Hayi': 'Nein',
      'Igama lam ngu ...': 'Mein Name ist ...',
      'Uvela phi?': 'Woher kommen Sie?',
      'Ndivela e ...': 'Ich komme aus ...',
      'Amanzi': 'Wasser',
      'Isonka': 'Brot',
      'Isibhedlele': 'Krankenhaus',
      'Ikhemesti': 'Apotheke',
      'Isitishi sikaloliwe': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'xhosa': 'Molo! Uyathetha isiJamani?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'xhosa': 'Ewe, ndifunda isiJamani ngoku.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'xhosa': 'Nceda, iphi ikhemesti ekufuphi?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'xhosa': 'Enkosi kakhulu ngoncedo lwakho!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
