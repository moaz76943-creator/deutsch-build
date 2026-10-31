import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Romanian (Limba română).
///
/// Eastern Romance language spoken by 25M+ people with over 800,000 in Germany and Austria.
/// Uniquely preserves the 3-gender system (masculin, feminin, neutru) directly matching
/// German der, die, das, exact 1:1 match of letter 'Ț/ț' to German 'Z/z' (/ts/) and
/// 'Ș/ș' to German 'SCH' (/ʃ/), enclitic definite articles, and a 2-case inflected system.
@immutable
class RomanianDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasThreeGenders; // Masculin, Feminin, Neutru matching der, die, das!
  final bool hasNativeGermanZSound; // Romanian 'ț' = German 'z' (/ts/)!
  final bool hasNativeGermanSCHSound; // Romanian 'ș' = German 'sch' (/ʃ/)!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const RomanianDeepLocalizationProfile({
    this.languageName = 'Romanian',
    this.autonym = 'Limba română',
    this.iso6391 = 'ro',
    this.iso6392 = 'ron',
    this.languageFamily = 'Indo-European',
    this.branch = 'Romance (Eastern Romance / Balkan Romance)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Romanian alphabet)',
    this.specialCharacters = const ['ă', 'â', 'î', 'ș', 'ț'],
    this.hasThreeGenders = true,
    this.hasNativeGermanZSound = true, // 'ț' is strictly /ts/
    this.hasNativeGermanSCHSound = true, // 'ș' is strictly /ʃ/
    this.wordOrder = 'SVO',
    this.genderEquivalenceMap = const {
      'Genul masculin (-ul)': 'German Maskulinum (der) - e.g., bărbatul (der Mann), pomul (der Baum).',
      'Genul feminin (-a)': 'German Femininum (die) - e.g., femeia (die Frau), școala (die Schule).',
      'Genul neutru (-ul / -ele)': 'German Neutrum (das) - e.g., scaunul/scaunele (der Stuhl/das Ding), teatrul (das Theater).',
    },
    this.caseSystemAlignment = const {
      '1. Nominativ (Cine? Ce?)': 'Subject form. Matches German Nominativ (Wer? Was? - bărbatul).',
      '2. Acuzativ (Pe cine? Ce?)': 'Direct object; takes "pe" for specific people (îl văd pe bărbat). Matches German Akkusativ (den Mann).',
      '3. Dativ (Cui?)': 'Recipient suffix -lui / -i (bărbatului / femeii). Directly matches German Dativ (dem Mann / der Frau).',
      '4. Genitiv (Al/A/Ai/Ale cui?)': 'Possession suffix identical to Dative (cartea bărbatului). Directly matches German Genitiv (des Mannes).',
      '5. Vocativ': 'Direct respectful address (Bărbate!). Matches German direct address.',
      'Instrumentalis (Cu)': 'Preposition "cu" (cu prietenul). Matches German Dativ with preposition "mit".',
      'Lokativ (În / La)': 'Prepositions "în", "la" (în oraș). Matches German Dativ with static preposition "in".',
    },
    this.culturalIslamicLexicon = const {
      'bună ziua / salut / selam': 'Guten Tag / Begrüßung / Friede (Arabic: سلام)',
      'mulțumesc / mulțumesc frumos': 'Danke / Vielen Dank',
      'vă rog / te rog': 'Bitte',
      'carte': 'Buch',
      'școală / medresă': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'profesor / învățător': 'Lehrer / Dozent',
      'știință / cunoaștere': 'Wissen / Wissenschaft',
      'dreptate / justiție': 'Gerechtigkeit',
      'rugăciune / namaz': 'Gebet / Salāt (Persian: نماز)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'prieten': 'Freund',
      'apă': 'Wasser',
      'pâine': 'Brot / Nahrung',
      'casă': 'Haus / Heim',
      'oraș': 'Stadt',
      'spital': 'Krankenhaus',
      'farmacie': 'Apotheke',
      'geamie / moschee': 'Moschee (Turkish/Arabic: cami / مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Romanian "Ț / ț" is strictly /ts/ (e.g. țară, țintă, viață), matching German "z" (Zeit, Ziel, Zimmer) flawlessly!',
      'sch /ʃ/': '100% Native Identity! Romanian "Ș / ș" is strictly /ʃ/ (e.g. școală, oraș, șofer), matching German "sch" (Schule, schön) perfectly!',
      'tsch /tʃ/': 'Direct 1:1 match to Romanian "C(e) / C(i)" (ceai, cineva, Deutschland).',
      'ch /x/ (ach-Laut)': 'Direct match to Romanian "H / h" before back vowels (hrană, horn, Bach, Nacht).',
      '3-Gender Advantage': 'Romanian is the only Romance language retaining the neuter gender, removing the conceptual hurdle in acquiring German "das".',
    },
    this.coreA1Vocabulary = const {
      'Bună ziua / Salut': 'Hallo / Guten Tag',
      'Bună dimineața': 'Guten Morgen',
      'Bună ziua': 'Guten Tag',
      'Bună seara': 'Guten Abend',
      'Vă mulțumesc foarte mult': 'Vielen Dank',
      'Vă rog': 'Bitte',
      'Da': 'Ja',
      'Nu': 'Nein',
      'Mă numesc ...': 'Mein Name ist ...',
      'De unde sunteți?': 'Woher kommen Sie?',
      'Sunt din ...': 'Ich komme aus ...',
      'Apă': 'Wasser',
      'Pâine': 'Brot',
      'Spital': 'Krankenhaus',
      'Farmacie': 'Apotheke',
      'Gară': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'romanian': 'Bună ziua! Vorbiți limba germană?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'romanian': 'Da, învăț limba germană acum.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'romanian': 'Vă rog, unde este cea mai apropiată farmacie?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'romanian': 'Vă mulțumesc foarte mult pentru ajutor!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Romanian case relation into its German equivalent.
  String? getGermanCaseBridge(String relationName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(relationName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
