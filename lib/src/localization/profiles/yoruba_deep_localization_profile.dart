import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Yoruba (Èdè Yorùbá).
///
/// Major Niger-Congo language (Volta-Niger branch) spoken by 50M+ people in Nigeria,
/// Benin, and Togo. Characterized by 3 phonemic tones (High, Mid, Low), isolating
/// SVO morphology, Serial Verb Constructions (SVCs), and omnidirectional cross-lingual
/// transfer across tonal and non-tonal world languages.
@immutable
class YorubaDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final List<String> toneRegisters;
  final Map<String, String> serialVerbBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const YorubaDeepLocalizationProfile({
    this.languageName = 'Yoruba',
    this.autonym = 'Èdè Yorùbá',
    this.iso6391 = 'yo',
    this.iso6392or3 = 'yor',
    this.typology = TypologicalClassification.isolatingAnalytic,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.analyticalPrepositional,
    this.hasTones = true,
    this.hasGrammaticalGender = false,
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Yoruba alphabet with underdots ẹ, ọ, ṣ)',
    this.toneRegisters = const ['Àmì Ohùn Òkè (High tone - acute)', 'Àmì Ohùn Àárín (Mid tone - unmarked)', 'Àmì Ohùn Ìsàlẹ̀ (Low tone - grave)'],
    this.serialVerbBridge = const {
      'Serial Verb Construction (SVC)': 'Yoruba chains multiple verbs without conjunctions to express action sequences (ó mú ìwé wá = he took book came = er brachte das Buch). Mapped to German verb prefixes and complex predicates.',
      'Prepositional Case Markers': 'Prepositions (fún = Dativ/für, ti = Genitiv, pẹ̀lú = mit, ní = in/an) map directly into German case declensions.',
    },
    this.culturalIslamicLexicon = const {
      'báwo / àlàáfíà / salama': 'Hallo / Begrüßung / Friede (Arabic root: عافية / سلام)',
      'ẹ ṣe / o ṣeun púpọ̀': 'Danke / Vielen Dank',
      'ẹ jọ̀wọ́ / jọ̀wọ́': 'Bitte',
      'ìwé': 'Buch',
      'ilé-ìwé / mádárásà': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'olùkọ́': 'Lehrer / Dozent',
      'ìmọ̀ / ẹ̀kọ́': 'Wissen / Wissenschaft',
      'ìdájọ́ òdodo': 'Gerechtigkeit',
      'ìrun / kíkírun': 'Gebet / Salāt',
      'hàláàlì': 'Erlaubt / Halal (Arabic: حلال)',
      'ọ̀rẹ́': 'Freund',
      'omi': 'Wasser',
      'búrẹ́dì': 'Brot / Nahrung',
      'ilé': 'Haus / Heim',
      'ìlú': 'Stadt',
      'ilé-ìwòsàn': 'Krankenhaus',
      'ilé-oògùn': 'Apotheke',
      'mọ́ṣálásí': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Yoruba "Ṣ / ṣ" (ṣọ́ọ̀ṣì, Schule, schön).',
      'z /ts/': 'Yoruba lacks native affricates; German "z" is practiced as compound "t+s" (tsunami -> Zeit).',
      'ch /x/ (ach-Laut)': 'Mapped via velar friction contrasting with Yoruba "h" and velar plosives.',
      'Tonal Pitch Modulation': 'Yoruba native sensitivity to 3 pitch levels trains learners to master German sentence intonation questions vs declarative cadence.',
    },
    this.coreA1Vocabulary = const {
      'Báwo / Ẹ n lẹ́ o': 'Hallo / Guten Tag',
      'Ẹ káàárọ̀': 'Guten Morgen',
      'Ẹ káàsán': 'Guten Tag',
      'Ẹ kúalẹ́': 'Guten Abend',
      'Ẹ ṣe púpọ̀': 'Vielen Dank',
      'Ẹ jọ̀wọ́': 'Bitte',
      'Bẹ́ẹ̀ni': 'Ja',
      'Bẹ́ẹ̀kọ́': 'Nein',
      'Orúkọ mi ni ...': 'Mein Name ist ...',
      'Níbo lo ti wá?': 'Woher kommen Sie?',
      'Mo wá láti ...': 'Ich komme aus ...',
      'Omi': 'Wasser',
      'Búrẹ́dì': 'Brot',
      'Ilé-ìwòsàn': 'Krankenhaus',
      'Ilé-oògùn': 'Apotheke',
      'Ibùdó ọkọ̀ ojú-irin': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'yoruba': 'Báwo! Ṣé o gbọ́ èdè Jámánì?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'yoruba': 'Bẹ́ẹ̀ni, mo ń kọ́ èdè Jámánì lọ́wọ́lọ́wọ́ báyìí.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'yoruba': 'Ẹ jọ̀wọ́, níbo ni ilé-oògùn tó súnmọ́ jù wà?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'yoruba': 'Ẹ ṣe púpọ̀ fún ìrànlọ́wọ́ yín!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
