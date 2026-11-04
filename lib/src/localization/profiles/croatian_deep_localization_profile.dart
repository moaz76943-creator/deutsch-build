import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Croatian (Hrvatski jezik).
///
/// South Slavic language spoken by 5.5M+ people in Croatia and diaspora across
/// Germany and Austria. Characterized by 3 grammatical genders directly matching
/// German der, die, das, a 7-case declension framework, puristic Slavic terminology,
/// and exact 1:1 match of letter 'C/c' to German 'Z/z' (/ts/).
@immutable
class CroatianDeepLocalizationProfile {
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
  final bool hasNativeGermanZSound; // Croatian 'c' = German 'z' (/ts/)!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const CroatianDeepLocalizationProfile({
    this.languageName = 'Croatian',
    this.autonym = 'Hrvatski jezik',
    this.iso6391 = 'hr',
    this.iso6392 = 'hrv',
    this.languageFamily = 'Indo-European',
    this.branch = 'South Slavic (Western)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Gaj\'s alphabet)',
    this.specialCharacters = const ['č', 'ć', 'dž', 'đ', 'š', 'ž'],
    this.hasThreeGenders = true,
    this.hasNativeGermanZSound = true, // 'c' is strictly /ts/
    this.wordOrder = 'SVO',
    this.genderEquivalenceMap = const {
      'Muški rod (Masculin)': 'German Maskulinum (der) - e.g., čovjek (der Mann), stol (der Tisch).',
      'Ženski rod (Feminin)': 'German Femininum (die) - e.g., žena (die Frau), knjiga (das Buch/fem in HR, die Schule).',
      'Srednji rod (Neutrum)': 'German Neutrum (das) - e.g., dijete (das Kind), selo (das Dorf).',
    },
    this.caseSystemAlignment = const {
      '1. Nominativ (Tko? Što?)': 'Subject form. Matches German Nominativ (Wer? Was? - der Mann).',
      '2. Genitiv (Koga? Čega?)': 'Possession and partitive. Matches German Genitiv (Wessen? - des Mannes).',
      '3. Dativ (Komu? Čemu?)': 'Indirect object / recipient. Matches German Dativ (Wem? - dem Mann).',
      '4. Akuzativ (Koga? Što?)': 'Direct object. Matches German Akkusativ (Wen? Was? - den Mann).',
      '5. Vokativ (Hej!)': 'Direct address (Prijatelju!). Matches German direct address.',
      '6. Lokativ (O komu? O čemu?)': 'Location and topic. Matches German Dativ with prepositions "in", "an", "o".',
      '7. Instrumental (S kim? Čim?)': 'Accompaniment or means. Matches German Dativ with preposition "mit".',
    },
    this.culturalIslamicLexicon = const {
      'dobar dan / selam': 'Guten Tag / Begrüßung / Friede (Arabic: سلام)',
      'hvala / hvala lijepa': 'Danke / Vielen Dank',
      'molim / izvolite': 'Bitte',
      'knjiga': 'Buch',
      'škola': 'Schule',
      'učitelj / učiteljica': 'Lehrer / Lehrerin',
      'znanje / znanost': 'Wissen / Wissenschaft',
      'pravda': 'Gerechtigkeit',
      'molitva / namaz': 'Gebet / Salāt (Persian: نماز)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'prijatelj': 'Freund',
      'voda': 'Wasser',
      'kruh': 'Brot / Nahrung',
      'kuća / dom': 'Haus / Heim',
      'grad': 'Stadt',
      'bolnica': 'Krankenhaus',
      'ljekarna': 'Apotheke',
      'džamija': 'Moschee (Arabic: جامع)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Croatian "C / c" is strictly /ts/ (e.g. cijena, cilj), matching German "z" (Zeit, Ziel, Zimmer) flawlessly!',
      'sch /ʃ/': 'Direct 1:1 match to Croatian "Š / š" (škola, šuma, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Croatian "Č / č" and "Ć / ć" (čaj, čaša, Deutschland).',
      'ch /x/ (ach-Laut)': 'Direct match to Croatian "H / h" (kruh, hrana, Bach, Nacht).',
      'Puristic Neologism Bridge': 'Croatian linguistic purism (e.g., zrakoplov for Flugzeug, kolodvor for Bahnhof) provides structural conceptual affinity for German compound nouns.',
    },
    this.coreA1Vocabulary = const {
      'Dobar dan / Bok': 'Hallo / Guten Tag',
      'Dobro jutro': 'Guten Morgen',
      'Dobar dan': 'Guten Tag',
      'Dobra večer': 'Guten Abend',
      'Hvala lijepa': 'Vielen Dank',
      'Molim': 'Bitte',
      'Da': 'Ja',
      'Ne': 'Nein',
      'Zovem se ...': 'Mein Name ist ...',
      'Odakle ste?': 'Woher kommen Sie?',
      'Ja sam iz ...': 'Ich komme aus ...',
      'Voda': 'Wasser',
      'Kruh': 'Brot',
      'Bolnica': 'Krankenhaus',
      'Ljekarna': 'Apotheke',
      'Željeznički kolodvor': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'croatian': 'Dobar dan! Govorite li njemački?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'croatian': 'Da, trenutno učim njemački jezik.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'croatian': 'Molim vas, gdje se nalazi najbliža ljekarna?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'croatian': 'Puno vam hvala na pomoći!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Croatian case to its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
