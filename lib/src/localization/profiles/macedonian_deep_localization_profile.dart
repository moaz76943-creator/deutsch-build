import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Macedonian (Македонски јазик).
///
/// South Slavic Balkan language spoken by 2.5M+ people. Characterized by a unique
/// 3-way spatial postposed definite article system (-от neutral, -ов proximal here,
/// -он distal there), analytical prepositional case syntax, fixed antepenultimate
/// stress, 3 genders matching der/die/das, and exact 1:1 match of 'Ц/ц' to German 'Z/z'.
@immutable
class MacedonianDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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

  /// This profile's documented gender inventory is masculine, feminine, neuter.
  bool get hasThreeGenders => hasGrammaticalGender;

  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final Map<String, String> threeWayArticleBridge;
  final Map<String, String> analyticalPrepositionalBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const MacedonianDeepLocalizationProfile({
    this.languageName = 'Macedonian',
    this.autonym = 'Македонски јазик',
    this.iso6391 = 'mk',
    this.iso6392or3 = 'mkd',
    this.typology = TypologicalClassification.isolatingAnalytic,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.analyticalPrepositional,
    this.hasTones = false, // Fixed antepenultimate stress!
    this.hasGrammaticalGender = true, // Машки, Женски, Среден род!
    this.writingDirection = 'ltr',
    this.primaryScript = 'Cyrillic (Macedonian alphabet)',
    this.specialCharacters = const ['Ѓ', 'ѓ', 'Ѕ', 'ѕ', 'Ј', 'ј', 'Љ', 'љ', 'Њ', 'њ', 'Ќ', 'ќ', 'Џ', 'џ'],
    this.threeWayArticleBridge = const {
      '3-Way Spatial Article System': 'Macedonian uniquely encodes distance in definite suffixes: -от/-та/-то (neutral definite = der/die/das), -ов/-ва/-во (proximal = dieser/dieses), -он/-на/-но (distal = jener/jenes). Gives learners extraordinary spatial precision!',
      'Fixed Antepenultimate Stress': 'Stress is strictly fixed on the third syllable from the end (училиштето), providing a regular, predictable acoustic rhythm.',
    },
    this.analyticalPrepositionalBridge = const {
      'Nominativ (Subject)': 'Direct subject form (човекот). Maps to German Nominativ (der Mann).',
      'Akkusativ (Direct Object)': 'Analytical object; clitic doubling for definites (го видов човекот). Maps to German Akkusativ (den Mann).',
      'Dativ / Genitiv (на / na)': 'Preposition "на" expresses both recipient and possession (книгата на човекот). Maps to German Dativ and Genitiv.',
      'Instrumentalis (со / so)': 'Preposition "со" (со пријателот). Maps to German Dativ with preposition "mit".',
      'Lokativ (во / на)': 'Prepositions "во", "на" (во градот). Maps to German Dativ with prepositions "in" and "an".',
    },
    this.culturalIslamicLexicon = const {
      'здраво / добар ден / селам': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'благодарам / многу благодарам': 'Danke / Vielen Dank',
      'молам': 'Bitte',
      'книга': 'Buch',
      'училиште / медреса': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'учител / наставник': 'Lehrer / Dozent',
      'знаење / наука': 'Wissen / Wissenschaft',
      'правда': 'Gerechtigkeit',
      'молитва / намаз': 'Gebet / Salāt (Persian: نماز)',
      'халал': 'Erlaubt / Halal (Arabic: حلال)',
      'пријател': 'Freund',
      'вода': 'Wasser',
      'леб': 'Brot / Nahrung',
      'куќа / дом': 'Haus / Heim',
      'град': 'Stadt',
      'болница': 'Krankenhaus',
      'аптека': 'Apotheke',
      'џамија': 'Moschee (Arabic: جامع)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Macedonian "Ц / ц" is strictly /ts/ (e.g. цена, циркус), matching German "z" (Zeit, Zug, Zimmer) flawlessly!',
      'sch /ʃ/': 'Direct 1:1 match to Macedonian "Ш / ш" (училиште, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Macedonian "Ч / ч" (чај, Deutschland).',
      'ch /x/ (ach-Laut)': 'Direct match to Macedonian "Х / х" (леб, Bach, Nacht).',
    },
    this.coreA1Vocabulary = const {
      'Здраво / Добар ден': 'Hallo / Guten Tag',
      'Добро утро': 'Guten Morgen',
      'Добар ден': 'Guten Tag',
      'Добро вечер': 'Guten Abend',
      'Многу благодарам': 'Vielen Dank',
      'Молам': 'Bitte',
      'Да': 'Ja',
      'Не': 'Nein',
      'Моето име е ...': 'Mein Name ist ...',
      'Од каде сте?': 'Woher kommen Sie?',
      'Јас сум од ...': 'Ich komme aus ...',
      'Вода': 'Wasser',
      'Леб': 'Brot',
      'Болница': 'Krankenhaus',
      'Аптека': 'Apotheke',
      'Жолозничка станица': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'macedonian': 'Добар ден! Дали зборувате германски?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'macedonian': 'Да, во моментов учам германски јазик.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'macedonian': 'Молам, каде се наоѓа најблиската аптека?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'macedonian': 'Ви благодарам многу за помошта!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
