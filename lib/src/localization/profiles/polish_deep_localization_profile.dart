import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Polish (Język polski).
///
/// West Slavic language spoken by 45M+ people in Poland and over 800,000 in Germany.
/// Features Latin script with rich diacritics (ą, ć, ę, ł, ń, ó, ś, ź, ż),
/// a 3-gender system matching German der/die/das, a 7-case declension system,
/// exact 1:1 match of letter 'C/c' to German 'Z/z' (/ts/), and shared historic
/// lexical cognates through centuries of German-Polish cross-border contact.
@immutable
class PolishDeepLocalizationProfile {
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
  final bool hasNativeGermanZSound; // Polish 'c' = German 'z' (/ts/)!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> sharedCognateBridges;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const PolishDeepLocalizationProfile({
    this.languageName = 'Polish',
    this.autonym = 'Język polski',
    this.iso6391 = 'pl',
    this.iso6392 = 'pol',
    this.languageFamily = 'Indo-European',
    this.branch = 'West Slavic (Lechitic)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Polish alphabet)',
    this.specialCharacters = const ['ą', 'ć', 'ę', 'ł', 'ń', 'ó', 'ś', 'ź', 'ż'],
    this.hasThreeGenders = true,
    this.hasNativeGermanZSound = true, // 'c' is strictly /ts/
    this.wordOrder = 'SVO',
    this.genderEquivalenceMap = const {
      'Rodzaj męski (Masculin)': 'German Maskulinum (der) - e.g., stół (der Tisch), człowiek (der Mensch).',
      'Rodzaj żeński (Feminin)': 'German Femininum (die) - e.g., książka (das Buch/fem in PL, die Schule).',
      'Rodzaj nijaki (Neutrum)': 'German Neutrum (das) - e.g., okno (das Fenster), dziecko (das Kind).',
    },
    this.caseSystemAlignment = const {
      '1. Mianownik (Nominativ - Kto? Co?)': 'Direct subject. Matches German Nominativ (Wer? Was? - der Mann).',
      '2. Dopełniacz (Genitiv - Kogo? Czego?)': 'Possession and negation. Matches German Genitiv (Wessen? - des Mannes).',
      '3. Celownik (Dativ - Komu? Czemu?)': 'Indirect object / recipient. Matches German Dativ (Wem? - dem Mann).',
      '4. Biernik (Akkusativ - Kogo? Co?)': 'Direct object. Matches German Akkusativ (Wen? Was? - den Mann).',
      '5. Narzędnik (Instrumentalis - Z kim? Z czym?)': 'Accompaniment or means. Matches German Dativ with preposition "mit".',
      '6. Miejscownik (Lokativ - O kim? O czym?)': 'Location and topic. Matches German Dativ with prepositions "in", "an".',
      '7. Wołacz (Vokativ)': 'Direct respectful address. Matches German direct address.',
    },
    this.sharedCognateBridges = const {
      'szynka': 'German "Schinken" (Schinken / Ham).',
      'burmistrz': 'German "Bürgermeister" (Bürgermeister / Mayor).',
      'ratusz': 'German "Rathaus" (Rathaus / City Hall).',
      'handel': 'German "Handel" (Handel / Trade).',
      'cukier': 'German "Zucker" (Zucker / Sugar).',
      'dach': 'German "Dach" (Dach / Roof).',
      'farba': 'German "Farbe" (Farbe / Paint).',
    },
    this.culturalIslamicLexicon = const {
      'dzień dobry / salam': 'Guten Tag / Begrüßung / Friede (Arabic: سلام)',
      'dziękuję / dziękuję bardzo': 'Danke / Vielen Dank',
      'proszę': 'Bitte',
      'książka': 'Buch',
      'szkoła': 'Schule',
      'nauczyciel / nauczycielka': 'Lehrer / Lehrerin',
      'wiedza / nauka': 'Wissen / Wissenschaft',
      'sprawiedliwość': 'Gerechtigkeit',
      'modlitwa / namaz': 'Gebet / Salāt (Persian: نماز)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'przyjaciel': 'Freund',
      'woda': 'Wasser',
      'chleb': 'Brot / Nahrung',
      'dom': 'Haus / Heim',
      'miasto': 'Stadt',
      'szpital': 'Krankenhaus',
      'apteka': 'Apotheke',
      'meczet': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Polish "C / c" is strictly /ts/ (e.g. cena, cytryna), matching German "z" (Zeit, Zug, Zimmer) flawlessly!',
      'sch /ʃ/': 'Direct 1:1 match to Polish "Sz / sz" (szkoła, szafa, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Polish "Cz / cz" (czas, czekolada, Deutschland).',
      'ch /x/ (ach-Laut)': 'Direct 1:1 match to Polish "Ch / ch" and "H / h" (chleb, dach, Bach, Nacht).',
      'Consonant Cluster Advantage': 'Polish native mastery of complex consonant clusters (np. sprzedaż, strona) makes German onset clusters (Sprache, Straße) completely effortless!',
    },
    this.coreA1Vocabulary = const {
      'Dzień dobry / Cześć': 'Hallo / Guten Tag',
      'Dzień dobry (rano)': 'Guten Morgen',
      'Dzień dobry': 'Guten Tag',
      'Dobry wieczór': 'Guten Abend',
      'Dziękuję bardzo': 'Vielen Dank',
      'Proszę': 'Bitte',
      'Tak': 'Ja',
      'Nie': 'Nein',
      'Nazywam się ...': 'Mein Name ist ...',
      'Skąd Pan/Pani jest?': 'Woher kommen Sie?',
      'Jestem z ...': 'Ich komme aus ...',
      'Woda': 'Wasser',
      'Chleb': 'Brot',
      'Szpital': 'Krankenhaus',
      'Apteka': 'Apotheke',
      'Dworzec kolejowy': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'polish': 'Dzień dobry! Czy mówi Pan/Pani po niemiecku?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'polish': 'Tak, obecnie uczę się języka niemieckiego.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'polish': 'Przepraszam, gdzie znajduje się najbliższa apteka?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'polish': 'Bardzo dziękuję za pomoc!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Polish case to its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
