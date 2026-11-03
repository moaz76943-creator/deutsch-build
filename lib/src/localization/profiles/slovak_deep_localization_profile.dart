import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Slovak (Slovenčina).
///
/// West Slavic language spoken by 5.5M+ people ("Slavic Esperanto").
/// Features Latin script with 46 letters (including ä matching German ä directly),
/// rhythmic law, 3 genders matching German der/die/das, a 6-case active system,
/// and exact 1:1 match of letter 'C/c' to German 'Z/z' (/ts/).
@immutable
class SlovakDeepLocalizationProfile {
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
  final bool hasNativeGermanZSound; // Slovak 'c' = German 'z' (/ts/)!
  final bool hasNativeGermanASound; // Slovak 'ä' = German 'ä' (/ɛ/)!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const SlovakDeepLocalizationProfile({
    this.languageName = 'Slovak',
    this.autonym = 'Slovenčina',
    this.iso6391 = 'sk',
    this.iso6392 = 'slk',
    this.languageFamily = 'Indo-European',
    this.branch = 'West Slavic (Czech-Slovak)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Slovak alphabet)',
    this.specialCharacters = const ['á', 'ä', 'č', 'ď', 'dz', 'dž', 'é', 'í', 'ĺ', 'ľ', 'ň', 'ó', 'ô', 'ŕ', 'š', 'ť', 'ú', 'ý', 'ž'],
    this.hasThreeGenders = true,
    this.hasNativeGermanZSound = true,
    this.hasNativeGermanASound = true, // 'ä' is native in Slovak!
    this.wordOrder = 'SVO',
    this.genderEquivalenceMap = const {
      'Mužský rod (Masculin)': 'German Maskulinum (der) - e.g., stôl (der Tisch), muž (der Mann).',
      'Ženský rod (Feminin)': 'German Femininum (die) - e.g., kniha (das Buch/fem in SK, die Schule).',
      'Stredný rod (Neutrum)': 'German Neutrum (das) - e.g., okno (das Fenster), dieťa (das Kind).',
    },
    this.caseSystemAlignment = const {
      '1. Nominatív (Kto? Čo?)': 'Subject form. Matches German Nominativ (Wer? Was? - der Mann).',
      '2. Genitív (Koho? Čoho?)': 'Possession and partitive. Matches German Genitiv (Wessen? - des Mannes).',
      '3. Datív (Komu? Čomu?)': 'Indirect object / recipient. Matches German Dativ (Wem? - dem Mann).',
      '4. Akuzatív (Koho? Čo?)': 'Direct object. Matches German Akkusativ (Wen? Was? - den Mann).',
      '5. Lokál (O kom? O čom?)': 'Location and topic. Matches German Dativ with prepositions "in", "an", "o".',
      '6. Inštrumentál (S kým? S čím?)': 'Accompaniment or means. Matches German Dativ with preposition "mit".',
    },
    this.culturalIslamicLexicon = const {
      'dobrý deň / selam': 'Guten Tag / Begrüßung / Friede (Arabic: سلام)',
      'ďakujem / ďakujem pekne': 'Danke / Vielen Dank',
      'prosím': 'Bitte',
      'kniha': 'Buch',
      'škola': 'Schule',
      'učiteľ / učiteľka': 'Lehrer / Lehrerin',
      'vedomosť / veda': 'Wissen / Wissenschaft',
      'spravodlivosť': 'Gerechtigkeit',
      'modlitba / namáz': 'Gebet / Salāt (Persian: نماز)',
      'halál': 'Erlaubt / Halal (Arabic: حلال)',
      'priateľ / kamarát': 'Freund',
      'voda': 'Wasser',
      'chlieb': 'Brot / Nahrung',
      'dom': 'Haus / Heim',
      'mesto': 'Stadt',
      'nemocnica': 'Krankenhaus',
      'lekáreň': 'Apotheke',
      'mešita': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Slovak "C / c" is strictly /ts/ (e.g. cesta, cena), matching German "z" (Zeit, Zimmer) flawlessly!',
      'ä /ɛ/': '100% Native Identity! Slovak "Ä / ä" (mäso, päť) directly matches German "ä" (Männer, Äpfel) with zero pronunciation adjustment!',
      'sch /ʃ/': 'Direct 1:1 match to Slovak "Š / š" (škola, šaty, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Slovak "Č / č" (čas, čaj, Deutschland).',
      'ch /x/ (ach-Laut)': 'Direct match to Slovak "Ch / ch" (chlieb, chyba, Bach, Nacht).',
    },
    this.coreA1Vocabulary = const {
      'Dobrý deň / Ahoj': 'Hallo / Guten Tag',
      'Dobré ráno': 'Guten Morgen',
      'Dobré popoludnie': 'Guten Tag',
      'Dobrý večer': 'Guten Abend',
      'Ďakujem pekne': 'Vielen Dank',
      'Prosím': 'Bitte',
      'Áno': 'Ja',
      'Nie': 'Nein',
      'Volám sa ...': 'Mein Name ist ...',
      'Odkiaľ ste?': 'Woher kommen Sie?',
      'Som z ...': 'Ich komme aus ...',
      'Voda': 'Wasser',
      'Chlieb': 'Brot',
      'Nemocnica': 'Krankenhaus',
      'Lekáreň': 'Apotheke',
      'Železničná stanica': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'slovak': 'Dobrý deň! Hovoríte po nemecky?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'slovak': 'Áno, momentálne sa učím nemecký jazyk.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'slovak': 'Prosím vás, kde sa nachádza najbližšia lekáreň?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'slovak': 'Veľmi pekne vám ďakujem za pomoc!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Slovak case into its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
