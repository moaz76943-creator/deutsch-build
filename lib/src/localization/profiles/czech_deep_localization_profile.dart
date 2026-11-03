import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Czech (Čeština).
///
/// West Slavic language spoken by 11M+ people; direct neighbor of Germany (Bavaria & Saxony).
/// Features Latin script with háček and čárka diacritics, unique alveolar trill 'ř' (/r̝/),
/// long vowel distinctions parallel to German quantity, 3 genders matching German der/die/das,
/// a 7-case declension system, and exact 1:1 match of letter 'C/c' to German 'Z/z' (/ts/).
@immutable
class CzechDeepLocalizationProfile {
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
  final bool hasNativeGermanZSound; // Czech 'c' = German 'z' (/ts/)!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const CzechDeepLocalizationProfile({
    this.languageName = 'Czech',
    this.autonym = 'Čeština',
    this.iso6391 = 'cs',
    this.iso6392 = 'ces',
    this.languageFamily = 'Indo-European',
    this.branch = 'West Slavic (Czech-Slovak)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Czech alphabet with háček and čárka)',
    this.specialCharacters = const ['á', 'č', 'ď', 'é', 'ě', 'í', 'ň', 'ó', 'ř', 'š', 'ť', 'ú', 'ů', 'ý', 'ž'],
    this.hasThreeGenders = true,
    this.hasNativeGermanZSound = true, // 'c' is strictly /ts/
    this.wordOrder = 'SVO',
    this.genderEquivalenceMap = const {
      'Rod mužský (Masculin)': 'German Maskulinum (der) - e.g., stůl (der Tisch), muž (der Mann).',
      'Rod ženský (Feminin)': 'German Femininum (die) - e.g., kniha (das Buch/fem in CS, die Schule).',
      'Rod střední (Neutrum)': 'German Neutrum (das) - e.g., okno (das Fenster), dítě (das Kind).',
    },
    this.caseSystemAlignment = const {
      '1. pád: Nominativ (Kdo? Co?)': 'Subject form. Matches German Nominativ (Wer? Was? - der Mann).',
      '2. pád: Genitiv (Koho? Čeho?)': 'Possession and partitive. Matches German Genitiv (Wessen? - des Mannes).',
      '3. pád: Dativ (Komu? Čemu?)': 'Indirect object / recipient. Matches German Dativ (Wem? - dem Mann).',
      '4. pád: Akuzativ (Koho? Co?)': 'Direct object. Matches German Akkusativ (Wen? Was? - den Mann).',
      '5. pád: Vokativ (Voláme)': 'Direct address (Pane profesore!). Matches German direct address.',
      '6. pád: Lokál (O kom? O čem?)': 'Location and topic. Matches German Dativ with prepositions "in", "an", "o".',
      '7. pád: Instrumentál (S kým? S čím?)': 'Accompaniment or means. Matches German Dativ with preposition "mit".',
    },
    this.culturalIslamicLexicon = const {
      'dobrý den / selam': 'Guten Tag / Begrüßung / Friede (Arabic: سلام)',
      'děkuji / děkuji mnohokrát': 'Danke / Vielen Dank',
      'prosím': 'Bitte',
      'kniha': 'Buch',
      'škola': 'Schule',
      'učitel / učitelka': 'Lehrer / Lehrerin',
      'vědění / věda': 'Wissen / Wissenschaft',
      'spravedlnost': 'Gerechtigkeit',
      'modlitba / namáz': 'Gebet / Salāt (Persian: نماز)',
      'halál': 'Erlaubt / Halal (Arabic: حلال)',
      'přítel / kamarád': 'Freund',
      'voda': 'Wasser',
      'chléb': 'Brot / Nahrung',
      'dům': 'Haus / Heim',
      'město': 'Stadt',
      'nemocnice': 'Krankenhaus',
      'lékárna': 'Apotheke',
      'mešita': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Czech "C / c" is strictly /ts/ (e.g. cena, cíl), matching German "z" (Zeit, Ziel, Zimmer) with zero acoustic distortion!',
      'sch /ʃ/': 'Direct 1:1 match to Czech "Š / š" (škola, šaty, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Czech "Č / č" (čas, čaj, Deutschland).',
      'ch /x/ (ach-Laut)': 'Direct match to Czech "Ch / ch" (chléb, chyba, Bach, Nacht).',
      'Vowel Quantity Bridge': 'Czech phonemic vowel length (krátké vs dlouhé samohlásky: a vs á, e vs é) directly prepares learners for German vowel length contrasts (Bann vs Bahn).',
    },
    this.coreA1Vocabulary = const {
      'Dobrý den / Ahoj': 'Hallo / Guten Tag',
      'Dobré ráno': 'Guten Morgen',
      'Dobré odpoledne': 'Guten Tag',
      'Dobrý večer': 'Guten Abend',
      'Děkuji mnohokrát': 'Vielen Dank',
      'Prosím': 'Bitte',
      'Ano': 'Ja',
      'Ne': 'Nein',
      'Jmenuji se ...': 'Mein Name ist ...',
      'Odkud jste?': 'Woher kommen Sie?',
      'Jsem z ...': 'Ich komme aus ...',
      'Voda': 'Wasser',
      'Chléb': 'Brot',
      'Nemocnice': 'Krankenhaus',
      'Lékárna': 'Apotheke',
      'Vlakové nádraží': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'czech': 'Dobrý den! Mluvíte německy?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'czech': 'Ano, v současné době se učím německý jazyk.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'czech': 'Prosím vás, kde je nejbližší lékárna?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'czech': 'Mnohokrát vám děkuji za pomoc!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Czech case into its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
