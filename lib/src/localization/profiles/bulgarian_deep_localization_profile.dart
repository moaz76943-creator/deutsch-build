import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Bulgarian (Български език).
///
/// South Slavic Balkan language spoken by 8M+ people. Unique among Slavic tongues
/// for its analytical structure (loss of noun cases, analytical prepositions),
/// postposed definite articles (-ът/-а, -та, -то) directly matching German der/die/das,
/// 3 grammatical genders, and exact 1:1 match of letter 'Ц/ц' to German 'Z/z' (/ts/).
@immutable
class BulgarianDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasThreeGenders;
  final bool isAnalytical; // No noun cases - prepositional structure!
  final bool hasPostposedDefiniteArticles; // -ът, -та, -то
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> analyticalCaseBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const BulgarianDeepLocalizationProfile({
    this.languageName = 'Bulgarian',
    this.autonym = 'Български език',
    this.iso6391 = 'bg',
    this.iso6392 = 'bul',
    this.languageFamily = 'Indo-European',
    this.branch = 'South Slavic (Eastern / Balkan Sprachbund)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Cyrillic (Bulgarian alphabet)',
    this.specialCharacters = const ['ъ', 'ь', 'ю', 'я'],
    this.hasThreeGenders = true,
    this.isAnalytical = true,
    this.hasPostposedDefiniteArticles = true,
    this.wordOrder = 'SVO',
    this.genderEquivalenceMap = const {
      'Мъжки род (Masculin)': 'German Maskulinum (der) - e.g., мъжът (der Mann), столът (der Tisch).',
      'Женски род (Feminin)': 'German Femininum (die) - e.g., жената (die Frau), книгата (das Buch/fem in BG, die Schule).',
      'Среден род (Neutrum)': 'German Neutrum (das) - e.g., детето (das Kind), селото (das Dorf).',
    },
    this.analyticalCaseBridge = const {
      'Nominativ (Подлог)': 'Unmarked noun or with full article -ът/-ят (мъжът чете). Maps to German Nominativ (der Mann liest).',
      'Akkusativ (Пряко допълнение)': 'Analytical object, short article -а/-я for masculines. Maps to German Akkusativ (den Mann).',
      'Dativ (Непряко допълнение - на)': 'Formed analytically with preposition "на" (давам на мъжа). Maps to German Dativ (ich gebe dem Mann).',
      'Genitiv (Притежание - на)': 'Formed analytically with preposition "на" (книгата на мъжа). Maps to German Genitiv (das Buch des Mannes).',
      'Instrumentalis (С / Със)': 'Preposition "с / със" (с приятеля). Maps to German Dativ with preposition "mit".',
      'Lokativ (В / Във / На)': 'Prepositions "в / във / на" (в града). Maps to German Dativ with prepositions "in" and "an".',
    },
    this.culturalIslamicLexicon = const {
      'добър ден / селям': 'Guten Tag / Begrüßung / Friede (Arabic: سلام)',
      'благодаря / благодаря много': 'Danke / Vielen Dank',
      'моля': 'Bitte',
      'книга': 'Buch',
      'училище': 'Schule',
      'учител / учителка': 'Lehrer / Lehrerin',
      'знание / наука': 'Wissen / Wissenschaft',
      'справедливост': 'Gerechtigkeit',
      'молитва / намаз': 'Gebet / Salāt (Persian: نماز)',
      'халал': 'Erlaubt / Halal (Arabic: حلال)',
      'приятел': 'Freund',
      'вода': 'Wasser',
      'хляб': 'Brot / Nahrung',
      'къща / дом': 'Haus / Heim',
      'град': 'Stadt',
      'болница': 'Krankenhaus',
      'аптека': 'Apotheke',
      'джамия': 'Moschee (Arabic: جامع)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Bulgarian "Ц / ц" is strictly /ts/ (e.g. център, цирк), matching German "z" (Zeit, Zug, Zimmer) flawlessly!',
      'sch /ʃ/': 'Direct 1:1 match to Bulgarian "Ш / ш" (училище, шапка, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Bulgarian "Ч / ч" (чай, човек, Deutschland).',
      'ch /x/ (ach-Laut)': 'Direct match to Bulgarian "Х / х" (хляб, хубав, Bach, Nacht).',
      'Article Inversion Bridge': 'Bulgarian uses postposed articles (-ът, -та, -то), requiring cognitive training to invert to German preposed articles (der, die, das).',
    },
    this.coreA1Vocabulary = const {
      'Здравейте / Добър ден': 'Hallo / Guten Tag',
      'Добро утро': 'Guten Morgen',
      'Добър ден': 'Guten Tag',
      'Добър вечер': 'Guten Abend',
      'Благодаря много': 'Vielen Dank',
      'Моля': 'Bitte',
      'Да': 'Ja',
      'Не': 'Nein',
      'Казвам се ...': 'Mein Name ist ...',
      'Откъде сте?': 'Woher kommen Sie?',
      'Аз съм от ...': 'Ich komme aus ...',
      'Вода': 'Wasser',
      'Хляб': 'Brot',
      'Болница': 'Krankenhaus',
      'Аптека': 'Apotheke',
      'ЖП гара': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'bulgarian': 'Добър ден! Говорите ли немски?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'bulgarian': 'Да, в момента уча немски език.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'bulgarian': 'Моля, къде се намира най-близката аптека?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'bulgarian': 'Много ви благодаря за помощта!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Bulgarian analytical case structure into its German equivalent.
  String? getGermanCaseBridge(String relationName) {
    for (final entry in analyticalCaseBridge.entries) {
      if (entry.key.toLowerCase().contains(relationName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
