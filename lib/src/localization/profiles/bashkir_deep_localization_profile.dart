import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Bashkir (Башҡорт теле / Başqort tele).
///
/// Turkic language family (Kipchak-Bulgar branch) spoken by 1.5M+ people in the
/// Volga-Ural region. Uniquely features native interdental fricatives (ҫ /θ/, ҙ /ð/),
/// native triple German umlauts (Ә/ә = ä, Ө/ө = ö, Ү/ү = ü), strict vowel harmony,
/// agglutinative 6-case morphology, and SOV clause architecture.
@immutable
class BashkirDeepLocalizationProfile {
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
  final bool hasInterdentalFricatives; // ҫ (/θ/) and ҙ (/ð/)
  final bool hasAllThreeGermanUmlauts; // Ә (ä), Ө (ö), Ү (ü)
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const BashkirDeepLocalizationProfile({
    this.languageName = 'Bashkir',
    this.autonym = 'Башҡорт теле',
    this.iso6391 = 'ba',
    this.iso6392 = 'bak',
    this.languageFamily = 'Turkic',
    this.branch = 'Kipchak (Kipchak-Bulgar)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Cyrillic (Bashkir alphabet)',
    this.specialCharacters = const ['Ғ', 'ғ', 'Ҙ', 'ҙ', 'Ҡ', 'ҡ', 'Ң', 'ң', 'Ө', 'ө', 'Ҫ', 'ҫ', 'Ү', 'ү', 'Һ', 'һ', 'Ә', 'ә'],
    this.isAgglutinative = true,
    this.hasInterdentalFricatives = true,
    this.hasAllThreeGermanUmlauts = true, // 100% native match for ä, ö, and ü!
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'Төп килеш (Nominativ)': 'Unmarked base form (китап). Directly maps to German Nominativ (das Buch).',
      'Эйәлек килеш (Genitiv)': 'Suffix -дың / -дең / -доң / -дөң (китаптың). Directly maps to German Genitiv (des Buches).',
      'Төбәү килеш (Dativ / Allativ)': 'Suffix -ға / -гә / -ғо / -гө (мәктәпкә). Maps to German Dativ & prepositions (zu, nach).',
      'Төшөм килеш (Akkusativ)': 'Suffix -ды / -де / -до / -дө (китапты). Directly maps to German definite Akkusativ (das Buch / den Mann).',
      'Урын-ваҡыт килеш (Lokativ)': 'Suffix -да / -дә / -та / -тә (мәктәптә). Maps to German Dativ with static prepositions (in, an).',
      'Сығыш килеш (Ablativ)': 'Suffix -дан / -дән / -тан / -тән (мәктәптән). Maps to German Dativ with source prepositions (aus, von).',
    },
    this.culturalIslamicLexicon = const {
      'һаумыһығыҙ / сәләм': 'Hallo / Friede / Begrüßung (Arabic: سلام)',
      'рәхмәт / оло рәхмәт': 'Danke / Barmherzigkeit (Arabic: رحمة)',
      'зинһар / рәхим итегеҙ': 'Bitte / Seien Sie willkommen (Arabic: رحمة)',
      'китап': 'Buch (Arabic: كتاب)',
      'мәктәп': 'Schule (Arabic: مكتب)',
      'уҡытыусы / мөғәллим': 'Lehrer (Arabic: معلم)',
      'ғилем / белем': 'Wissen / Wissenschaft (Arabic: علم)',
      'ғәҙеллек': 'Gerechtigkeit (Arabic: عدالة)',
      'намаҙ': 'Gebet / Salāt (Persian/Arabic: نماز / صلاة)',
      'хәләл': 'Erlaubt / Halal (Arabic: حلال)',
      'дуҫ': 'Freund (Persian: دوست)',
      'һыу': 'Wasser',
      'икмәк': 'Brot / Nahrung',
      'өй / йорт': 'Haus / Heim',
      'ҡала': 'Stadt',
      'хастахана': 'Krankenhaus (Persian: خسته خانه)',
      'дарыухана': 'Apotheke (Persian: داروخانه)',
      'мәсет': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'Triple Umlaut Identity (ä, ö, ü)': '100% Native Triad! Bashkir natively possesses ALL THREE German umlauts: "Ә/ә" = "ä", "Ө/ө" = "ö", "Ү/ү" = "ü" (e.g. әсәй, өй, үлән), eliminating any pronunciation barrier for German vowels!',
      'h /h/': 'Direct 1:1 match to Bashkir soft glottal "Һ / һ" (һау, haben, heute).',
      'sch /ʃ/': 'Direct 1:1 match to Bashkir "Ш / ш" (ҡала, Schule, schön).',
      'ch /x/ (ach-Laut)': 'Direct match to Bashkir "Х / х" (хат, Bach, Nacht).',
      'z /ts/': 'Practiced as compound "т+с" to distinguish from Bashkir native interdental "ҫ" /θ/.',
    },
    this.coreA1Vocabulary = const {
      'Һаумыһығыҙ / Сәләм': 'Hallo / Guten Tag',
      'Хәйерле иртә': 'Guten Morgen',
      'Хәйерле көн': 'Guten Tag',
      'Хәйерле кис': 'Guten Abend',
      'Оло рәхмәт': 'Vielen Dank',
      'Зинһар': 'Bitte',
      'Эйе': 'Ja',
      'Юҡ': 'Nein',
      'Минең исемем ...': 'Mein Name ist ...',
      'Һеҙ ҡайҙан?': 'Woher kommen Sie?',
      'Мин ...-дан/дән': 'Ich komme aus ...',
      'Һыу': 'Wasser',
      'Икмәк': 'Brot',
      'Хастахана': 'Krankenhaus',
      'Дарыухана': 'Apotheke',
      'Тимер юл вокзалы': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'bashkir': 'Һаумыһығыҙ! Һеҙ немецса һөйләшәһегеҙме?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'bashkir': 'Эйе, мин хәҙер немец телен өйрәнәм.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'bashkir': 'Зинһар, иң яҡын дарыухана ҡайҙа урынлашҡан?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'bashkir': 'Ярҙамығыҙ өсөн оло рәхмәт!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Bashkir case suffix to its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
