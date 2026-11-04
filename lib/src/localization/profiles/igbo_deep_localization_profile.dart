import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Igbo (Ásụ̀sụ́ Ìgbò).
///
/// Volta-Niger language spoken by 45M+ people in Nigeria. Characterized by
/// Ọ́nwụ́ orthography, 2 basic tones + downstep, Advanced Tongue Root (ATR) vowel
/// harmony, isolating SVO morphology, verbal compounding extensional affixes,
/// and omnidirectional cross-linguistic alignment across tonal and non-tonal tongues.
@immutable
class IgboDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final List<String> onwuSpecialGraphemes;
  final Map<String, String> verbalCompoundingBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const IgboDeepLocalizationProfile({
    this.languageName = 'Igbo',
    this.autonym = 'Ásụ̀sụ́ Ìgbò',
    this.iso6391 = 'ig',
    this.iso6392or3 = 'ibo',
    this.typology = TypologicalClassification.isolatingAnalytic,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.analyticalPrepositional,
    this.hasTones = true,
    this.hasGrammaticalGender = false,
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Ọ́nwụ́ alphabet with underdots ị, ọ, ụ)',
    this.onwuSpecialGraphemes = const ['ch', 'gb', 'gh', 'gw', 'kp', 'kw', 'nw', 'ny', 'sh', 'ị', 'ọ', 'ụ'],
    this.verbalCompoundingBridge = const {
      'Verbal Extensional Suffixes': 'Igbo attaches functional directional and aspectual suffixes to verbal roots (e.g., -bata enter, -pụ go out). Directly maps to German separable prefixes (herein-, hinaus-).',
      'Prepositional Case Markers': 'Preposition "na" (location, time, instrument) and associative marker "nke" (Genitive) map to German case and preposition networks.',
    },
    this.culturalIslamicLexicon = const {
      'ndewo / kedu / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'dalu / daalụ / imela': 'Danke / Vielen Dank',
      'biko': 'Bitte',
      'akwụkwọ': 'Buch',
      'ụlọ akwụkwọ / madrassa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'onye nkuzi': 'Lehrer / Dozent',
      'ihe ọmụma / sayensị': 'Wissen / Wissenschaft',
      'ikpe ziri ezi': 'Gerechtigkeit',
      'ekpere / salah': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'enyi': 'Freund',
      'mmiri': 'Wasser',
      'achịcha': 'Brot / Nahrung',
      'ụlọ': 'Haus / Heim',
      'obodo': 'Stadt',
      'ụlọ ọgwụ': 'Krankenhaus',
      'ụlọ ahịa ọgwụ': 'Apotheke',
      'ụlọ alakụba': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Igbo "Sh / sh" (ahịa / Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Igbo "Ch / ch" (chọọ, Deutschland).',
      'z /ts/': 'Igbo lacks native affricates; German "z" is practiced as compound "t+s" (tsunami -> Zeit).',
      'Tone and Stress Bridge': 'Igbo native mastery of High, Low, and Downstep pitch registers provides acute sensitivity for German lexical stress and question pitch contours.',
    },
    this.coreA1Vocabulary = const {
      'Ndewo / Kedu': 'Hallo / Guten Tag',
      'Ụtụtụ ọma': 'Guten Morgen',
      'Ehihie ọma': 'Guten Tag',
      'Mgbede ọma': 'Guten Abend',
      'Daalụ nke ukwuu': 'Vielen Dank',
      'Biko': 'Bitte',
      'Ee': 'Ja',
      'Mba': 'Nein',
      'Aha m bụ ...': 'Mein Name ist ...',
      'Ebee ka ị si?': 'Woher kommen Sie?',
      'M si na ...': 'Ich komme aus ...',
      'Mmiri': 'Wasser',
      'Achịcha': 'Brot',
      'Ụlọ ọgwụ': 'Krankenhaus',
      'Ụlọ ahịa ọgwụ': 'Apotheke',
      'Ọdụ ụgbọ okporo ígwè': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'igbo': 'Ndewo! Ị na-asụ German?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'igbo': 'Ee, m na-amụ asụsụ German ugbu a.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'igbo': 'Biko, ebee ka ụlọ ahịa ọgwụ kacha nso dị?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'igbo': 'Daalụ nke ukwuu maka enyemaka gị!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
