import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Chechen (Нохчийн мотт / Noxçiyn mott).
///
/// Northeast Caucasian (Nakh) language spoken by 1.7M+ people in Chechnya and
/// diaspora across Germany, Austria, and France. Characterized by ergative-absolutive
/// alignment, 6 noun classes (gender markers v, j, d, b), an 8-case system, rich
/// vowel inventories with umlaut fronting, and exact 1:1 match of letter 'Ц/ц' to German 'Z/z' (/ts/).
@immutable
class ChechenDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasErgativeAlignment;
  final bool hasNounClasses; // 6 noun classes (v, j, d, b)
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const ChechenDeepLocalizationProfile({
    this.languageName = 'Chechen',
    this.autonym = 'Нохчийн мотт',
    this.iso6391 = 'ce',
    this.iso6392 = 'che',
    this.languageFamily = 'Northeast Caucasian',
    this.branch = 'Nakh',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Cyrillic (with palochka Ӏ) / Latin',
    this.specialCharacters = const ['Ӏ', 'ӏ', 'аь', 'оь', 'уь', 'юь', 'яь'],
    this.hasErgativeAlignment = true,
    this.hasNounClasses = true,
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      '1. Цӏерниг (Absolutive / Nominativ)': 'Direct object of transitive verb or subject of intransitive. Maps to German Nominativ/Akkusativ.',
      '2. Доланиг (Genitiv - -ан / -ин)': 'Possession and relations (кӏентан). Directly maps to German Genitiv (des Jungen).',
      '3. Лург (Dativ - -на)': 'Recipient or beneficiary (кӏантана). Directly maps to German Dativ (dem Jungen).',
      '4. Дийриг (Ergativ - -о / -с)': 'Subject/agent of transitive verb (кӏанта дийцира). Maps to German transitive subject.',
      '5. Коьчалниг (Instrumentalis - -ца)': 'Accompaniment or means (кӏантаца). Directly maps to German Dativ with preposition "mit".',
      '6. Хотталург (Allativ - -га)': 'Direction toward person/place. Directly maps to German Dativ with preposition "zu".',
      '7. Дустург (Komparativ - -л)': 'Comparison marker (хьол лекха). Directly maps to German preposition "als" (größer als du).',
      '8. Меттигниг (Lokativ - -хь)': 'Location inside or at. Directly maps to German Dativ with static prepositions "in" and "an".',
    },
    this.culturalIslamicLexicon = const {
      'марша догӏийла / салам': 'Willkommen / Friede / Begrüßung (Arabic: سلام)',
      'баркалла': 'Danke (Arabic: بارك الله - Baraka Allah)',
      'дехар до': 'Bitte',
      'книга / жайна': 'Buch',
      'школа / хьуьжар': 'Schule / Medrese (Arabic: حجرة / مدرسة)',
      'хьехархо / муӏалим': 'Lehrer / Dozent (Arabic: معلم)',
      'ӏилма': 'Wissen / Wissenschaft (Arabic: علم)',
      'бакъо / ӏадалат': 'Gerechtigkeit / Recht (Arabic: عدالة)',
      'ламаз': 'Gebet / Salāt (Persian: نماز)',
      'хьанал': 'Erlaubt / Halal (Arabic: حلال)',
      'доттагӏ': 'Freund',
      'хи': 'Wasser',
      'бепиг': 'Brot / Nahrung',
      'цӏа': 'Haus / Heim',
      'гӏала': 'Stadt',
      'дарбанцӏа': 'Krankenhaus',
      'аптека': 'Apotheke',
      'маьждиг': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Chechen "Ц / ц" is strictly /ts/ (e.g. цӏа, цхьаъ), matching German "z" (Zeit, Zug, Zimmer) flawlessly!',
      'sch /ʃ/': 'Direct 1:1 match to Chechen "Ш / ш" (школа, Schule, schön).',
      'ch /x/ (ach-Laut)': 'Direct match to Chechen "Х / х" (хи, хабар, Bach, Nacht).',
      'tsch /tʃ/': 'Direct 1:1 match to Chechen "Ч / ч" (чай, чехка, Deutschland).',
      'Umlaut Fronting Bridge': 'Chechen possesses phonemic fronted vowels (аь, оь, уь matching ä, ö, ü directly), giving Chechen learners an innate acoustic foundation for German umlauts!',
    },
    this.coreA1Vocabulary = const {
      'Маршалла ду шуьга / Салам': 'Hallo / Guten Tag',
      'ӏуьйре дика хуьлда': 'Guten Morgen',
      'Де дика хуьлда': 'Guten Tag',
      'Суьйре дика хуьлда': 'Guten Abend',
      'Дела реза хуьлда / Баркалла': 'Vielen Dank',
      'Дехар до': 'Bitte',
      'Хӏаъ': 'Ja',
      'Хӏан-хӏа': 'Nein',
      'Сан цӏе ... ю': 'Mein Name ist ...',
      'Мичара ву/ю хьо?': 'Woher kommen Sie?',
      'Со ...-ра ву/ю': 'Ich komme aus ...',
      'Хи': 'Wasser',
      'Бепиг': 'Brot',
      'Дарбанцӏа': 'Krankenhaus',
      'Аптека': 'Apotheke',
      'Вокзал / Аьчка некъан вокзал': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'chechen': 'Де дика хуьлда! Немецкийн маттахь дуьйций ахь?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'chechen': 'Хӏаъ, аса хӏинца немцойн мотт ӏамош бу.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'chechen': 'Дехар до, уггар уллера аптека мичахь ю?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'chechen': 'ГӀодарна баркалла!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Chechen case into its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
