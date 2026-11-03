import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Wolof (Kàllaama Wolof).
///
/// Senegambian language spoken by 12M+ people in Senegal, The Gambia, and Mauritania.
/// Characterized by 8 singular noun classes (b, g, j, k, l, m, s, w) with proximity
/// determiners (near/far), non-tonal morphology, SVO syntax, verbal focus particles,
/// and deep Murid Sufi Islamic scholarly vocabulary.
@immutable
class WolofDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final Map<String, String> spatialDeterminerBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const WolofDeepLocalizationProfile({
    this.languageName = 'Wolof',
    this.autonym = 'Kàllaama Wolof',
    this.iso6391 = 'wo',
    this.iso6392or3 = 'wol',
    this.typology = TypologicalClassification.isolatingAnalytic,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.analyticalPrepositional,
    this.hasTones = false, // Unique non-tonal trait among West African languages
    this.hasGrammaticalGender = true, // 8 noun classes with spatial suffixes
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (official Senegalese alphabet) / Wolofal (Ajami)',
    this.nounClassCount = 8,
    this.spatialDeterminerBridge = const {
      'Spatial Determiner Concord': 'Wolof noun determiners encode physical distance: near speaker (-ii), near listener (-uu), remote (-aa). Maps directly to German demonstratives (dieser/jener) and spatial locative prepositions.',
      'Verbal Focus Markers': 'Focus particles (moo for subject focus, la for object focus, dafa for verb focus) bridge directly to German topicalization and inversion in V2 main clauses.',
    },
    this.culturalIslamicLexicon = const {
      'salaam alaykum / na nga def': 'Hallo / Begrüßung / Friede (Arabic: سلام عليكم)',
      'jërëjëf / jërëjëf lool': 'Danke / Vielen Dank',
      'baal ma / su la neexee': 'Bitte / Verzeih mir',
      'téere': 'Buch',
      'daara / ekool': 'Schule / Bildungsstätte (Arabic: دار)',
      'jàngalekat / sëriñ': 'Lehrer / Gelehrter (Wolof: Sëriñ)',
      'xam-xam': 'Wissen / Wissenschaft',
      'yoon / jub': 'Gerechtigkeit / Wahrheit',
      'julli / ñaan': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'xarit': 'Freund',
      'ndox': 'Wasser',
      'mburu': 'Brot / Nahrung',
      'kër': 'Haus / Heim',
      'dëkk': 'Stadt',
      'lopitaal': 'Krankenhaus',
      'farmasi': 'Apotheke',
      'jàkka / jumaa': 'Moschee (Arabic: جامع)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Practiced via postalveolar articulation contrasting with Wolof alveolar /s/.',
      'tsch /tʃ/': 'Direct 1:1 match to Wolof "C / c" (/c/ or /tʃ/) (caabi, Deutschland).',
      'z /ts/': 'Practiced as compound "t+s" (tsunami -> Zeit).',
      'ch /x/ (ach-Laut)': 'Direct match to Wolof "X / x" (xam-xam, xarit, Bach, Nacht).',
      'Non-Tonal Advantage': 'Unlike most Sub-Saharan tongues, Wolof is non-tonal, allowing learners to focus immediately on German stress patterns without tonal interference.',
    },
    this.coreA1Vocabulary = const {
      'Salaam alaykum / Na nga def': 'Hallo / Guten Tag',
      'Jàmm nga am': 'Guten Morgen',
      'Naka bëccëg gi': 'Guten Tag',
      'Naka ngoon si': 'Guten Abend',
      'Jërëjëf lool': 'Vielen Dank',
      'Su la neexee': 'Bitte',
      'Waaw': 'Ja',
      'Déedéet': 'Nein',
      'Maa ngi tudd ...': 'Mein Name ist ...',
      'Fan nga jóge?': 'Woher kommen Sie?',
      'Maa ngi jóge ...': 'Ich komme aus ...',
      'Ndox': 'Wasser',
      'Mburu': 'Brot',
      'Lopitaal': 'Krankenhaus',
      'Farmasi': 'Apotheke',
      'Garu gare': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'wolof': 'Na nga def! Ndax danga deg làkku Almaañ?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'wolof': 'Waaw, maa ngi jàng làkku Almaañ léegi.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'wolof': 'Baal ma, fan la farmasi bi gën a jege nekk?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'wolof': 'Jërëjëf lool ci sa ndimbal!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
