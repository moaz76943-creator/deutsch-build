import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Hungarian (Magyar nyelv).
///
/// Uralic language (Ugric branch) spoken by 13M+ people in Hungary and Central Europe.
/// Features 18 grammatical cases, front/back/rounded vowel harmony, native short and
/// long umlauts (ö, ő, ü, ű) offering a 100% native acoustic match to German umlauts,
/// definite vs indefinite verb conjugation, and exact 1:1 match of letter 'C/c' to German 'Z/z' (/ts/).
@immutable
class HungarianDeepLocalizationProfile {
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
  final bool hasVowelHarmony;
  final bool hasNativeGermanUmlauts; // ö, ő, ü, ű match German ö and ü!
  final bool hasNativeGermanZSound; // Hungarian 'c' = German 'z' (/ts/)!
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const HungarianDeepLocalizationProfile({
    this.languageName = 'Hungarian',
    this.autonym = 'Magyar nyelv',
    this.iso6391 = 'hu',
    this.iso6392 = 'hun',
    this.languageFamily = 'Uralic',
    this.branch = 'Ugric',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Hungarian alphabet)',
    this.specialCharacters = const ['á', 'é', 'í', 'ó', 'ö', 'ő', 'ú', 'ü', 'ű'],
    this.isAgglutinative = true,
    this.hasVowelHarmony = true,
    this.hasNativeGermanUmlauts = true,
    this.hasNativeGermanZSound = true, // 'c' is strictly /ts/
    this.wordOrder = 'SVO / Topic-prominent',
    this.caseSystemAlignment = const {
      'Nominatívus (Alapeset)': 'Unmarked base form (a könyv). Directly maps to German Nominativ (das Buch).',
      'Akkuzatívus (-t)': 'Direct object suffix -t (a könyvet). Directly maps to German Akkusativ (das Buch / den Mann).',
      'Dativus (-nak / -nek)': 'Recipient or possessor suffix. Matches German Dativ (dem Mann / dem Buch).',
      'Inessivus (-ban / -ben - benne)': 'Location inside. Directly maps to German Dativ with static preposition "in".',
      'Illativus (-ba / -be - bele)': 'Direction into. Directly maps to German Akkusativ with directional preposition "in".',
      'Elativus (-ból / -ből - belőle)': 'Source out of. Directly maps to German Dativ with preposition "aus".',
      'Adessivus (-nál / -nél - nála)': 'Location at/by. Directly maps to German Dativ with prepositions "bei" and "an".',
      'Allativus (-hoz / -hez / -höz)': 'Direction toward. Directly maps to German Dativ with preposition "zu".',
      'Ablativus (-tól / -től - tőle)': 'Direction away from. Directly maps to German Dativ with preposition "von".',
      'Instrumentalis (-val / -vel)': 'Means or accompaniment. Directly maps to German Dativ with preposition "mit".',
    },
    this.culturalIslamicLexicon = const {
      'jó napot / szalam': 'Guten Tag / Begrüßung / Friede (Arabic: سلام)',
      'köszönöm / köszönöm szépen': 'Danke / Vielen Dank',
      'kérem / szívesen': 'Bitte / Gern geschehen',
      'könyv': 'Buch',
      'iskola / medresze': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'tanár / tanárnő': 'Lehrer / Lehrerin',
      'tudás / tudomány': 'Wissen / Wissenschaft',
      'igazságosság': 'Gerechtigkeit',
      'ima / namaz': 'Gebet / Salāt (Persian: نماز)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'barát': 'Freund',
      'víz': 'Wasser',
      'kenyér': 'Brot / Nahrung',
      'ház / otthon': 'Haus / Heim',
      'város': 'Stadt',
      'kórház': 'Krankenhaus',
      'gyógyszertár / patika': 'Apotheke',
      'dzsámi / mecset': 'Moschee (Arabic: جامع / مسجد)',
    },
    this.germanPhoneticBridges = const {
      'ö /ø/ & ü /y/': '100% Native Identity! Hungarian short and long umlauts (ö/ő, ü/ű: pl. öt, ősz, fül, tűz) match German short and long "ö" and "ü" (schön, über) with absolute acoustic perfection!',
      'z /ts/': '100% Native Identity! Hungarian "C / c" is strictly /ts/ (e.g. cica, cukor), matching German "z" (Zeit, Zug, Zimmer) flawlessly!',
      'sch /ʃ/': '100% Native Identity! Hungarian "S / s" is pronounced strictly /ʃ/ (e.g. sör, iskola), matching German "sch" (Schule, schön) perfectly!',
      's /z/': 'German voiced "s" /z/ (Sonne, Suppe) corresponds directly to Hungarian "Z / z" (zene, zár).',
      'ch /x/ (ach-Laut)': 'Mapped via Hungarian velar fricative "ch / h" (pl. technika, Bach, Nacht).',
    },
    this.coreA1Vocabulary = const {
      'Jó napot / Szervusz': 'Hallo / Guten Tag',
      'Jó reggelt': 'Guten Morgen',
      'Jó napot': 'Guten Tag',
      'Jó estét': 'Guten Abend',
      'Köszönöm szépen': 'Vielen Dank',
      'Kérem': 'Bitte',
      'Igen': 'Ja',
      'Nem': 'Nein',
      'A nevem ...': 'Mein Name ist ...',
      'Honnan származol?': 'Woher kommen Sie?',
      'Én ...-ból/ből jöttem': 'Ich komme aus ...',
      'Víz': 'Wasser',
      'Kenyér': 'Brot',
      'Kórház': 'Krankenhaus',
      'Gyógyszertár': 'Apotheke',
      'Vasútállomás': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'hungarian': 'Jó napot! Beszél németül?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'hungarian': 'Igen, jelenleg németül tanulok.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'hungarian': 'Kérem, hol található a legközelebbi gyógyszertár?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'hungarian': 'Nagyon szépen köszönöm a segítségét!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Hungarian case suffix into its German prepositional/case equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
