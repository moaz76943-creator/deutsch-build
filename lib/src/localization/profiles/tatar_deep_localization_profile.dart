import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Tatar (Татар теле / Tatar tele).
///
/// Turkic language family (Kipchak-Bulgar branch) spoken by 5.5M+ people in Tatarstan,
/// Bashkortostan, and the Volga-Ural region. Uniquely features all THREE German umlauts
/// natively (Ә/ä, Ө/ö, Ү/ü), strict front/back vowel harmony, agglutinative 6-case morphology,
/// SOV word order, and centuries-old Islamic scholarly vocabulary from Kazan.
@immutable
class TatarDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool isAgglutinative;
  final bool hasAllThreeGermanUmlauts; // Native Ә (ä), Ө (ö), Ү (ü)
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const TatarDeepLocalizationProfile({
    this.languageName = 'Tatar',
    this.autonym = 'Татар теле',
    this.iso6391 = 'tt',
    this.iso6392 = 'tat',
    this.languageFamily = 'Turkic',
    this.branch = 'Kipchak (Kipchak-Bulgar)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Cyrillic (official) / Latin (Yañalif)',
    this.specialCharacters = const ['Ә', 'ә', 'Ө', 'ө', 'Ү', 'ү', 'Җ', 'җ', 'Ң', 'ң', 'Һ', 'һ'],
    this.isAgglutinative = true,
    this.hasAllThreeGermanUmlauts = true, // 100% native match for ä, ö, and ü!
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'Төп килеш (Nominativ)': 'Unmarked base form (китап). Directly maps to German Nominativ (das Buch).',
      'Иялек килеше (Genitiv)': 'Suffix -ның / -нең (китапның). Directly maps to German Genitiv (des Buches).',
      'Юнәлеш килеше (Dativ / Allativ)': 'Suffix -га / -гә / -ка / -кә (мәктәпкә). Maps to German Dativ & prepositions (zu, nach).',
      'Төшем килеше (Akkusativ)': 'Suffix -ны / -не (китапны). Directly maps to German definite Akkusativ (das Buch / den Mann).',
      'Урын-вакыт килеше (Lokativ)': 'Suffix -да / -дә / -та / -тә (мәктәптә). Maps to German Dativ with static prepositions (in, an).',
      'Чыгыш килеше (Ablativ)': 'Suffix -дан / -дән / -тан / -тән (мәктәптән). Maps to German Dativ with source prepositions (aus, von).',
    },
    this.culturalIslamicLexicon = const {
      'сәлам / әссәламегаләйкем': 'Friede / Begrüßung (Arabic: سلام)',
      'рәхмәт': 'Danke / Barmherzigkeit (Arabic: رحمة)',
      'зинһар / рәхим итегез': 'Bitte / Seien Sie willkommen (Arabic: رحمة)',
      'китап': 'Buch (Arabic: كتاب)',
      'мәктәп': 'Schule (Arabic: مكتب)',
      'мөгаллим / укытучы': 'Lehrer (Arabic: معلم)',
      'гыйлем': 'Wissenschaft / Wissen (Arabic: علم)',
      'гаделлек': 'Gerechtigkeit (Arabic: عدالة)',
      'намаз': 'Gebet / Salāt (Persian/Arabic: نماز / صلاة)',
      'хәләл': 'Erlaubt / Halal (Arabic: حلال)',
      'дус': 'Freund (Persian: دوست)',
      'су': 'Wasser',
      'икмәк / ипи': 'Brot / Nahrung',
      'йорт / өй': 'Haus / Heim',
      'шәһәр': 'Stadt (Persian: شهر)',
      'хастаханә': 'Krankenhaus (Persian: خسته خانه)',
      'даруханә': 'Apotheke (Persian: داروخانه)',
    },
    this.germanPhoneticBridges = const {
      'Triple Umlaut Identity (ä, ö, ü)': '100% Native Triad! Tatar natively possesses ALL THREE German umlauts: "Ә/ә" = "ä", "Ө/ө" = "ö", "Ү/ү" = "ü" (e.g. әни, өй, үлән), eliminating any pronunciation barrier for German vowels!',
      'sch /ʃ/': 'Direct 1:1 match to Tatar "ш" (шәһәр, Schule, schön).',
      'ch /x/ (ach-Laut)': 'Direct match to Tatar "х" (хат, Bach, Nacht).',
      'h /h/': 'Direct match to Tatar soft glottal "һ" (һәм, haben).',
      'z /ts/': 'Tatar "з" is voiced /z/; German "z" is an affricate /ts/, practiced as "т+с" compound.',
    },
    this.coreA1Vocabulary = const {
      'Исәнмесез / Сәлам': 'Hallo / Guten Tag',
      'Хәерле иртә': 'Guten Morgen',
      'Хәерле көн': 'Guten Tag',
      'Хәерле кич': 'Guten Abend',
      'Зур рәхмәт': 'Vielen Dank',
      'Зинһар': 'Bitte',
      'Әйе': 'Ja',
      'Юк': 'Nein',
      'Минем исемем ...': 'Mein Name ist ...',
      'Сез кайдан?': 'Woher kommen Sie?',
      'Мин ...-дан/дән': 'Ich komme aus ...',
      'Су': 'Wasser',
      'Икмәк': 'Brot',
      'Хастаханә': 'Krankenhaus',
      'Даруханә': 'Apotheke',
      'Тимер юл вокзалы': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'tatar': 'Исәнмесез! Сез алманча сөйләшәсезме?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'tatar': 'Әйе, мин хәзер алман телен өйрәнәм.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'tatar': 'Зинһар, иң якын даруханә кайда урнашкан?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'tatar': 'Ярдәмегез өчен зур рәхмәт!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Confirms that Tatar natively possesses all three German umlauts: ä, ö, and ü.
  bool hasAllThreeGermanUmlautGraphemes() {
    return specialCharacters.contains('Ә') &&
        specialCharacters.contains('Ө') &&
        specialCharacters.contains('Ү');
  }

  /// Translates a Tatar case suffix to its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
