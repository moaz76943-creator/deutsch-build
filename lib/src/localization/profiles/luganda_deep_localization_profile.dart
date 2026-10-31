import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Luganda (Oluganda).
///
/// Great Lakes Bantu language spoken by 10M+ people in Uganda. Characterized by
/// 10 paired noun classes with initial vowel augment (pre-prefix e.g. o-mu-ntu / a-ba-ntu)
/// functioning as an inherent definiteness marker matching German der/die/das,
/// tone/vowel length contrasts, SVO syntax, and Buganda Islamic heritage.
@immutable
class LugandaDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final Map<String, String> initialAugmentArticleBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const LugandaDeepLocalizationProfile({
    this.languageName = 'Luganda',
    this.autonym = 'Oluganda',
    this.iso6391 = 'lg',
    this.iso6392or3 = 'lug',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = true,
    this.hasGrammaticalGender = true, // 10 paired noun classes!
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Luganda alphabet with ŋ)',
    this.nounClassCount = 10,
    this.initialAugmentArticleBridge = const {
      'Augment Pre-Prefix Definiteness': 'Luganda prefix initial vowels (o-mu-ntu = der Mensch / the person vs mu-ntu = ein Mensch / a person) function as inherent definite articles, providing an immediate mental anchor for German der, die, das.',
      '10-Noun-Class Concord': 'Nouns govern all-pervasive class prefix agreement on verbs and modifiers, easing German adjective declension and gender concord mastery.',
    },
    this.culturalIslamicLexicon = const {
      'ki kati / oli otya / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'weebale / weebale nnyo': 'Danke / Vielen Dank',
      'mwattu / nsaba': 'Bitte',
      'ekitabo': 'Buch (Arabic: كتاب)',
      'essomero / madrasa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'omusomesa / ustadh': 'Lehrer / Dozent (Arabic: أستاذ)',
      'okumanya / sayansi': 'Wissen / Wissenschaft',
      'obwenkanya': 'Gerechtigkeit',
      'okusaala / salat': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'mukwano': 'Freund',
      'amazzi': 'Wasser',
      'omugaati': 'Brot / Nahrung (Portuguese/Swahili loan: mkate)',
      'ennyumba': 'Haus / Heim',
      'ekibuga': 'Stadt',
      'eddwaliro': 'Krankenhaus',
      'ettendekero ly\'eddagala': 'Apotheke',
      'omuzikiti': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Luganda "Sy / sy" or postalveolar /ʃ/.',
      'tsch /tʃ/': 'Direct 1:1 match to Luganda "C / c" (/tʃ/) (cai, Deutschland).',
      'z /ts/': 'Luganda "z" is voiced /z/; German "z" is practiced as the compound sequence "t+s" (tsunami -> Zeit).',
      'ch /x/ (ach-Laut)': 'Mapped via velar friction contrasting with Luganda velar plosives.',
    },
    this.coreA1Vocabulary = const {
      'Ki kati / Oli otya': 'Hallo / Guten Tag',
      'Wasuze otya': 'Guten Morgen',
      'Osiibye otya': 'Guten Tag',
      'Osiibye otya (akawungeezi)': 'Guten Abend',
      'Weebale nnyo': 'Vielen Dank',
      'Mwattu': 'Bitte',
      'Ye': 'Ja',
      'Nedda': 'Nein',
      'Erinnya lyange nze ...': 'Mein Name ist ...',
      'Ova wa?': 'Woher kommen Sie?',
      'Nva mu ...': 'Ich komme aus ...',
      'Amazzi': 'Wasser',
      'Omugaati': 'Brot',
      'Eddwaliro': 'Krankenhaus',
      'Ettendekero ly\'eddagala': 'Apotheke',
      'Sitenseni y\'egaali y\'omukka': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'luganda': 'Oli otya! Oyogera Olugeremani?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'luganda': 'Ye, njiga Olugeremani kati.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'luganda': 'Mwattu, ettendekero ly\'eddagala erisinga okumpi liri wa?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'luganda': 'Weebale nnyo olw\'obuyambi bwo!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
