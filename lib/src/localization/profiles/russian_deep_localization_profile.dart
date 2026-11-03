import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Russian (Русский язык).
///
/// East Slavic language spoken by 258M+ people worldwide, with over 3.5M speakers
/// in Germany. Features 3 grammatical genders (мужской, женский, средний) directly
/// matching German der, die, das, a 6-case declension system, verbal aspect
/// (совершенный / несовершенный вид), and exact 1:1 match of letter 'Ц/ц' to German 'Z/z' (/ts/).
@immutable
class RussianDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final bool hasThreeGenders; // Exact match to German der, die, das!
  final bool hasNativeGermanZSound; // Russian 'ц' = German 'z' (/ts/)!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const RussianDeepLocalizationProfile({
    this.languageName = 'Russian',
    this.autonym = 'Русский язык',
    this.iso6391 = 'ru',
    this.iso6392 = 'rus',
    this.languageFamily = 'Indo-European',
    this.branch = 'East Slavic',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Cyrillic (Russian alphabet)',
    this.hasThreeGenders = true,
    this.hasNativeGermanZSound = true, // 'ц' is strictly /ts/
    this.wordOrder = 'SVO',
    this.genderEquivalenceMap = const {
      'Мужской род (Masculin)': 'German Maskulinum (der) - e.g., стол (der Tisch), человек (der Mensch).',
      'Женский род (Feminin)': 'German Femininum (die) - e.g., книга (das Buch/fem in RU, die Schule).',
      'Средний род (Neutrum)': 'German Neutrum (das) - e.g., окно (das Fenster), дитя (das Kind).',
    },
    this.caseSystemAlignment = const {
      '1. Именительный (Nominativ - Кто? Что?)': 'Direct subject. Matches German Nominativ (Wer? Was? - der Mann).',
      '2. Родительный (Genitiv - Кого? Чего?)': 'Possession and negation. Matches German Genitiv (Wessen? - des Mannes).',
      '3. Дательный (Dativ - Кому? Чему?)': 'Indirect object / recipient. Matches German Dativ (Wem? - dem Mann).',
      '4. Винительный (Akkusativ - Кого? Что?)': 'Direct object. Matches German Akkusativ (Wen? Was? - den Mann).',
      '5. Творительный (Instrumentalis - Кем? Чем?)': 'Instrument or accompaniment. Matches German Dativ with preposition "mit".',
      '6. Предложный (Lokativ - О ком? О чём?)': 'Location and topic. Matches German Dativ with prepositions "in", "an", "über".',
    },
    this.culturalIslamicLexicon = const {
      'здравствуйте / салам': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'спасибо / благодарю': 'Danke / Dankbarkeit',
      'пожалуйста': 'Bitte',
      'книга': 'Buch',
      'школа / медресе': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'учитель / преподаватель': 'Lehrer / Dozent',
      'знание / наука': 'Wissen / Wissenschaft',
      'справедливость / правосудие': 'Gerechtigkeit',
      'молитва / намаз': 'Gebet / Salāt (Persian: نماز)',
      'халяль / дозволенное': 'Erlaubt / Halal (Arabic: حلال)',
      'друг / товарищ': 'Freund',
      'вода': 'Wasser',
      'хлеб': 'Brot / Nahrung',
      'дом': 'Haus / Heim',
      'город': 'Stadt',
      'больница': 'Krankenhaus',
      'аптека': 'Apotheke',
      'мечеть': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Russian "Ц / ц" is strictly /ts/ (e.g. центр, цирк), matching German "z" (Zeit, Zug, Zimmer) flawlessly!',
      'sch /ʃ/': 'Direct match to Russian "Ш / ш" (школа, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Russian "Ч / ч" (чай, человек, Deutschland).',
      'ch /x/ (ach-Laut)': 'Direct match to Russian "Х / х" (хлеб, хорошо, Bach, Nacht).',
      'ch /ç/ (ich-Laut)': 'Palatal fricative practiced through soft palatal release (e.g. soft "хь"), avoiding velar back friction.',
      'Article System Drill': 'Because Russian lacks grammatical articles, learners receive targeted cognitive drills to map Russian noun genders to German der, die, das.',
    },
    this.coreA1Vocabulary = const {
      'Здравствуйте': 'Hallo / Guten Tag',
      'Доброе утро': 'Guten Morgen',
      'Добрый день': 'Guten Tag',
      'Добрый вечер': 'Guten Abend',
      'Большое спасибо': 'Vielen Dank',
      'Пожалуйста': 'Bitte',
      'Да': 'Ja',
      'Нет': 'Nein',
      'Меня зовут ...': 'Mein Name ist ...',
      'Откуда вы?': 'Woher kommen Sie?',
      'Я из ...': 'Ich komme aus ...',
      'Вода': 'Wasser',
      'Хлеб': 'Brot',
      'Больница': 'Krankenhaus',
      'Аптека': 'Apotheke',
      'Вокзал / Железнодорожная станция': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'russian': 'Здравствуйте! Вы говорите по-немецки?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'russian': 'Да, я сейчас изучаю немецкий язык.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'russian': 'Скажите, пожалуйста, где находится ближайшая аптека?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'russian': 'Большое спасибо за вашу помощь!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Russian case to its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
