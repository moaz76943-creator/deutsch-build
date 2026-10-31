import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Fulani / Fulfulde (Pulaar / Fulfulde).
///
/// Senegambian language spoken by 40M+ people across 18 West/Central African nations.
/// Famed for possessing 20 to 25 distinct noun classes (the world's most intricate
/// gender agreement system, rendering German der/die/das effortless!), initial
/// consonant mutation, SVO syntax, and profound Islamic scholarly history.
@immutable
class FulaniDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final int nounClassCount; // 20 to 25 noun classes!
  final Map<String, String> nounClassAdvantageBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const FulaniDeepLocalizationProfile({
    this.languageName = 'Fulani',
    this.autonym = 'Fulfulde / Pulaar',
    this.iso6391 = 'ff',
    this.iso6392or3 = 'ful',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = false,
    this.hasGrammaticalGender = true, // 20+ noun classes/genders!
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (with hooked letters ɓ, ɗ, ƴ) / historic Ajami',
    this.nounClassCount = 25,
    this.nounClassAdvantageBridge = const {
      '25-Noun-Class Mastery': 'Fulfulde operates 20-25 distinct noun classes (o-class humans, ɗam-class liquids, ki-class trees, etc.). Because Fulani learners already master complex morphological concord across 25 genders, German\'s 3-gender system (der, die, das) is instantly grasped with zero conceptual friction!',
      'Initial Consonant Mutation': 'Grammatical alternations (pullo -> fulɓe) prepare learners for German umlaut mutations (Mann -> Männer, Buch -> Bücher).',
    },
    this.culturalIslamicLexicon = const {
      'jam / no wa\'i / salam': 'Hallo / Friede / Begrüßung (Arabic: سلام)',
      'a jaaraama / barke alla': 'Danke / Baraka Allah (Arabic: بارك الله)',
      'tiiɗno / njaafee': 'Bitte',
      'deftere': 'Buch (Arabic: دفتر)',
      'jangirde / madrasa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'jannginoowo / cerno': 'Lehrer / Gelehrter (Pulaar: cerno)',
      'gandal': 'Wissen / Wissenschaft',
      'nunɗal': 'Gerechtigkeit',
      'juulde / salāt': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'yigoo / higo': 'Freund',
      'ndiyam': 'Wasser',
      'mburu': 'Brot / Nahrung',
      'suudu': 'Haus / Heim',
      'wuro / saare': 'Stadt',
      'opitool': 'Krankenhaus',
      'suudu lekki': 'Apotheke',
      'juulirde': 'Moschee (Pulaar: juulde)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct match to Fulfulde palatal/postalveolar fricatives.',
      'tsch /tʃ/': 'Direct 1:1 match to Fulfulde "C / c" (/c/ or /tʃ/) (cerno, Deutschland).',
      'z /ts/': 'Practiced as compound "t+s" (tsunami -> Zeit).',
      'ch /x/ (ach-Laut)': 'Mapped via velar release contrasting with Fulfulde aspirated consonants.',
    },
    this.coreA1Vocabulary = const {
      'Jam waali / No wa\'i': 'Hallo / Guten Tag',
      'Jam waali (subaka)': 'Guten Morgen',
      'Jam ñalli': 'Guten Tag',
      'Jam hiiri': 'Guten Abend',
      'A jaaraama no feewi': 'Vielen Dank',
      'Tiiɗno': 'Bitte',
      'Eey': 'Ja',
      'Alaa': 'Nein',
      'Innde am ko ...': 'Mein Name ist ...',
      'Hoto njey-ɗaa?': 'Woher kommen Sie?',
      'Mi jeyaa ko ...': 'Ich komme aus ...',
      'Ndiyam': 'Wasser',
      'Mburu': 'Brot',
      'Opitool': 'Krankenhaus',
      'Suudu lekki': 'Apotheke',
      'Gaar / Gare': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'fulani': 'Jam waali! Aɗa wolwa ɗemngal Almaañ?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'fulani': 'Eey, miɗo jannga ɗemngal Almaañ jooni.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'fulani': 'Tiiɗno, hol to suudu lekki ɓurndu ɓadaade woni?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'fulani': 'A jaaraama no feewi e ballal maa!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
