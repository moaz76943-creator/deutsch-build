import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Italian (Italiano).
///
/// Italo-Dalmatian Romance language spoken by 65M+ people with over 800,000 in Germany.
/// Characterized by exact 1:1 match of letter 'Z/z' to German 'Z/z' (/ts/) (e.g. pizza,
/// stazione = Zeit, Zimmer), preposed definite articles (il/lo/la), contracted prepositions
/// (del/al/dal/nel matching German im/am/zum), congiuntivo mood, and consonant gemination.
@immutable
class ItalianDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasTwoGenders;
  final bool hasNativeGermanZSound; // Italian 'z' = German 'z' (/ts/)!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const ItalianDeepLocalizationProfile({
    this.languageName = 'Italian',
    this.autonym = 'Italiano',
    this.iso6391 = 'it',
    this.iso6392 = 'ita',
    this.languageFamily = 'Indo-European',
    this.branch = 'Romance (Italo-Dalmatian)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Italian alphabet)',
    this.specialCharacters = const ['à', 'è', 'é', 'ì', 'ò', 'ó', 'ù'],
    this.hasTwoGenders = true,
    this.hasNativeGermanZSound = true, // 'z' in pizza, stazione is strictly /ts/!
    this.wordOrder = 'SVO',
    this.genderEquivalenceMap = const {
      'Genere maschile (il / lo)': 'German Maskulinum (der) - e.g., l\'uomo (der Mann), il libro (das Buch/masc in IT).',
      'Genere femminile (la)': 'German Femininum (die) - e.g., la donna (die Frau), la scuola (die Schule).',
      'Preposizioni articolate (del / al / nel)': 'Direct parallel to German article contractions: del = des (di+il), al = dem (a+il), nel = im (in+il).',
    },
    this.caseSystemAlignment = const {
      'Nominativ (Soggetto)': 'Direct subject without preposition. Matches German Nominativ (l\'uomo legge).',
      'Akkusativ (Complemento oggetto diretto)': 'Direct object without preposition (vedo l\'uomo). Matches German Akkusativ (ich sehe den Mann).',
      'Dativ (Complemento di termine - a)': 'Marked with preposition "a" (do il libro all\'uomo). Matches German Dativ (ich gebe dem Mann).',
      'Genitiv (Complemento di specificazione - di / del)': 'Marked with preposition "di" (il libro del professore). Matches German Genitiv (des Lehrers).',
      'Instrumentalis (Con)': 'Preposition "con" (con l\'amico). Matches German Dativ with preposition "mit".',
      'Lokativ (In / A)': 'Prepositions "in", "a" (nella città). Matches German Dativ with static preposition "in".',
    },
    this.culturalIslamicLexicon = const {
      'buongiorno / ciao / salam': 'Hallo / Guten Tag / Friede (Arabic: سلام)',
      'grazie / grazie mille': 'Danke / Vielen Dank',
      'per favore / prego': 'Bitte / Gern geschehen',
      'libro': 'Buch',
      'scuola': 'Schule',
      'insegnante / professore': 'Lehrer / Professor',
      'conoscenza / scienza': 'Wissen / Wissenschaft',
      'giustizia': 'Gerechtigkeit',
      'preghiera / salat': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'amico': 'Freund',
      'acqua': 'Wasser',
      'pane': 'Brot / Nahrung',
      'casa': 'Haus / Heim',
      'città': 'Stadt',
      'ospedale': 'Krankenhaus',
      'farmacia': 'Apotheke',
      'moschea': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Italian "Z / z" in words like pizza, stazione, canzone is strictly /ts/, matching German "z" (Zeit, Zug, Zimmer) with absolute perfection!',
      'sch /ʃ/': '100% Native Identity! Italian "Sc(i) / sc(e)" (scena, sciarpa) is strictly /ʃ/, matching German "sch" (Schule, schön) directly!',
      'tsch /tʃ/': '100% Native Identity! Italian "C(i) / c(e)" (ciao, cento) is strictly /tʃ/, matching German "tsch" (Deutschland, Tschechien) flawlessly!',
      'Consonant Gemination Bridge': 'Italian double consonants (notte, gatto, bello) train learners to naturally recognize German short vowels followed by double consonants (Bett, Wasser, voll).',
    },
    this.coreA1Vocabulary = const {
      'Buongiorno / Ciao': 'Hallo / Guten Tag',
      'Buongiorno (mattina)': 'Guten Morgen',
      'Buon pomeriggio': 'Guten Tag',
      'Buonasera': 'Guten Abend',
      'Grazie mille': 'Vielen Dank',
      'Per favore': 'Bitte',
      'Sì': 'Ja',
      'No': 'Nein',
      'Mi chiamo ...': 'Mein Name ist ...',
      'Da dove viene?': 'Woher kommen Sie?',
      'Vengo da ...': 'Ich komme aus ...',
      'Acqua': 'Wasser',
      'Pane': 'Brot',
      'Ospedale': 'Krankenhaus',
      'Farmacia': 'Apotheke',
      'Stazione ferroviaria': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'italian': 'Buongiorno! Parla tedesco?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'italian': 'Sì, sto imparando la lingua tedesca adesso.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'italian': 'Per favore, dov\'è la farmacia più vicina?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'italian': 'Grazie mille per il suo aiuto!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates an Italian prepositional relation into its German equivalent.
  String? getGermanCaseBridge(String relationName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(relationName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
