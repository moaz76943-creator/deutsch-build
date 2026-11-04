import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Ukrainian (Українська мова).
///
/// East Slavic language spoken by 40M+ people, with over 1.2M learners currently
/// residing in Germany. Characterized by 3 grammatical genders directly matching
/// German der, die, das, a 7-case declension system, distinctive glottal 'Г/г' (/ɦ/)
/// matching German 'h', and exact 1:1 match of letter 'Ц/ц' to German 'Z/z' (/ts/).
@immutable
class UkrainianDeepLocalizationProfile {
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
  final bool hasNativeGermanZSound; // Ukrainian 'ц' = German 'z' (/ts/)!
  final bool hasGlottalHSound; // Ukrainian 'г' = German 'h' (/ɦ/~/h/)!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const UkrainianDeepLocalizationProfile({
    this.languageName = 'Ukrainian',
    this.autonym = 'Українська мова',
    this.iso6391 = 'uk',
    this.iso6392 = 'ukr',
    this.languageFamily = 'Indo-European',
    this.branch = 'East Slavic',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Cyrillic (Ukrainian alphabet)',
    this.specialCharacters = const ['Ґ', 'ґ', 'Є', 'є', 'І', 'і', 'Ї', 'ї'],
    this.hasThreeGenders = true,
    this.hasNativeGermanZSound = true,
    this.hasGlottalHSound = true,
    this.wordOrder = 'SVO',
    this.genderEquivalenceMap = const {
      'Чоловічий рід (Masculin)': 'German Maskulinum (der) - e.g., стіл (der Tisch), хлопець (der Junge).',
      'Жіночий рід (Feminin)': 'German Femininum (die) - e.g., книжка (das Buch/fem in UK, die Schule).',
      'Середній рід (Neutrum)': 'German Neutrum (das) - e.g., вікно (das Fenster), дитя (das Kind).',
    },
    this.caseSystemAlignment = const {
      '1. Називний (Nominativ - Хто? Що?)': 'Direct subject. Matches German Nominativ (Wer? Was? - der Mann).',
      '2. Родовий (Genitiv - Кого? Чого?)': 'Possession and partitive. Matches German Genitiv (Wessen? - des Mannes).',
      '3. Давальний (Dativ - Кому? Чому?)': 'Indirect object / recipient. Matches German Dativ (Wem? - dem Mann).',
      '4. Знахідний (Akkusativ - Кого? Що?)': 'Direct object. Matches German Akkusativ (Wen? Was? - den Mann).',
      '5. Орудний (Instrumentalis - Ким? Чим?)': 'Means or accompaniment. Matches German Dativ with preposition "mit".',
      '6. Місцевий (Lokativ - На кому? На чому?)': 'Location. Matches German Dativ with prepositions "in", "an", "auf".',
      '7. Кличний (Vokativ - Звертання)': 'Direct respectful address. Matches German direct address.',
    },
    this.culturalIslamicLexicon = const {
      'добрий день / салам': 'Guten Tag / Begrüßung / Friede (Arabic: سلام)',
      'дякую / щиро дякую': 'Danke / Vielen Dank',
      'будь ласка': 'Bitte',
      'книга / книжка': 'Buch',
      'школа': 'Schule',
      'вчитель / викладач': 'Lehrer / Dozent',
      'знання / наука': 'Wissen / Wissenschaft',
      'справедливість': 'Gerechtigkeit',
      'молитва / намаз': 'Gebet / Salāt (Persian: نماز)',
      'халяль / дозволене': 'Erlaubt / Halal (Arabic: حلال)',
      'друг / товариш': 'Freund',
      'вода': 'Wasser',
      'хліб': 'Brot / Nahrung',
      'дім / будинок': 'Haus / Heim',
      'місто': 'Stadt',
      'лікарня': 'Krankenhaus',
      'аптека': 'Apotheke',
      'мечеть': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Ukrainian "Ц / ц" is strictly /ts/ (e.g. цукор, цирк), matching German "z" (Zeit, Zug, Zimmer) perfectly!',
      'h /h/ & /ɦ/': '100% Native Identity! Ukrainian "Г / г" is a voiced glottal fricative /ɦ/, providing an immediate, effortless bridge to German "h" (haben, heute, hier)!',
      'g /ɡ/': 'Ukrainian "Ґ / ґ" represents the hard voiced velar plosive /ɡ/, matching German "g" (gut, gehen, Geld).',
      'sch /ʃ/': 'Direct 1:1 match to Ukrainian "Ш / ш" (школа, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Ukrainian "Ч / ч" (чай, час, Deutschland).',
      'ch /x/ (ach-Laut)': 'Direct match to Ukrainian "Х / х" (хліб, хата, Bach, Nacht).',
    },
    this.coreA1Vocabulary = const {
      'Доброго дня / Привіт': 'Hallo / Guten Tag',
      'Доброго ранку': 'Guten Morgen',
      'Добрий день': 'Guten Tag',
      'Добрий вечір': 'Guten Abend',
      'Щиро дякую': 'Vielen Dank',
      'Будь ласка': 'Bitte',
      'Так': 'Ja',
      'Ні': 'Nein',
      'Мене звати ...': 'Mein Name ist ...',
      'Звідки ви?': 'Woher kommen Sie?',
      'Я з ...': 'Ich komme aus ...',
      'Вода': 'Wasser',
      'Хліб': 'Brot',
      'Лікарня': 'Krankenhaus',
      'Аптека': 'Apotheke',
      'Вокзал / Залізнична станція': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'ukrainian': 'Доброго дня! Чи говорите ви німецькою?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'ukrainian': 'Так, я зараз вивчаю німецьку мову.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'ukrainian': 'Підкажіть, будь ласка, де найближча аптека?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'ukrainian': 'Щиро дякую за вашу допомогу!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Ukrainian case to its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
