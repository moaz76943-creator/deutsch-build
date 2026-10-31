import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Slovenian (Slovenščina).
///
/// South Slavic language spoken by 2.5M+ people; direct neighbor to Austria (Carinthia).
/// Uniquely preserves the ancient dual grammatical number (Dvojina), 6 cases, 3 genders
/// matching German der/die/das exactly, exact 1:1 match of letter 'C/c' to German 'Z/z'
/// (/ts/) and 'Š/š' to German 'SCH' (/ʃ/), and profound Austro-Bavarian historic ties.
@immutable
class SlovenianDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
  @override
  final String languageName;
  @override
  final String autonym;
  @override
  final String iso6391;
  @override
  final String iso6392or3;
  @override
  final TypologicalClassification typology;
  @override
  final CanonicalWordOrder primaryWordOrder;
  @override
  final GrammaticalAlignment alignment;
  @override
  final bool hasTones;
  @override
  final bool hasGrammaticalGender;

  final String writingDirection;
  final String primaryScript;
  final bool hasDualGrammaticalNumber; // Dvojina!
  final Map<String, String> dualNumberBridge;
  final Map<String, String> sixCaseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const SlovenianDeepLocalizationProfile({
    this.languageName = 'Slovenian',
    this.autonym = 'Slovenščina',
    this.iso6391 = 'sl',
    this.iso6392or3 = 'slv',
    this.typology = TypologicalClassification.fusionalInflected,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = true, // Tonal pitch accent in standard Slovenian
    this.hasGrammaticalGender = true, // Moški, Ženski, Srednji spol!
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Gaj\'s alphabet with č, š, ž)',
    this.hasDualGrammaticalNumber = true,
    this.dualNumberBridge = const {
      'Dvojina (Dual Number Preservation)': 'Slovenian preserves distinct dual forms across nouns, adjectives, pronouns, and verbs (midva sva = wir beide sind; dve mesti = zwei Städte). When learning German, learners simply map dual concepts into plural while retaining high morphological precision.',
      '3-Gender Concord': 'Slovenian operates 3 grammatical genders natively (moški, ženski, srednji), providing a 100% natural mirror to German der, die, das.',
    },
    this.sixCaseSystemAlignment = const {
      '1. Imenovalnik (Nominativ - Kdo? Kaj?)': 'Direct subject. Matches German Nominativ (moški = der Mann).',
      '2. Rodilnik (Genitiv - Koga? Česa?)': 'Possession and negation. Matches German Genitiv (moškega = des Mannes).',
      '3. Dajalnik (Dativ - Komu? Čemu?)': 'Recipient / indirect object. Matches German Dativ (moškemu = dem Mann).',
      '4. Tožilnik (Akkusativ - Koga? Kaj?)': 'Direct object. Matches German Akkusativ (moškega = den Mann).',
      '5. Mestnik (Lokativ - Pri kom? Pri čem?)': 'Location inside or at. Matches German Dativ with prepositions "v", "na".',
      '6. Orodnik (Instrumentalis - S kom? S čim?)': 'Accompaniment or means. Matches German Dativ with preposition "mit".',
    },
    this.culturalIslamicLexicon = const {
      'dober dan / živjo / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'hvala / hvala lepa': 'Danke / Vielen Dank',
      'prosim': 'Bitte',
      'knjiga': 'Buch',
      'šola / medresa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'učitelj / profesor': 'Lehrer / Dozent',
      'znanje / znanost': 'Wissen / Wissenschaft',
      'pravica / pravičnost': 'Gerechtigkeit',
      'molitev / namaz': 'Gebet / Salāt (Persian: نماز)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'prijatelj': 'Freund',
      'voda': 'Wasser',
      'kruh': 'Brot / Nahrung',
      'hiša / dom': 'Haus / Heim',
      'mesto': 'Stadt',
      'bolnišnica': 'Krankenhaus',
      'lekarna': 'Apotheke',
      'mošeja / džamija': 'Moschee (Arabic: جامع / مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Slovenian "C / c" is strictly /ts/ (e.g. cena, center), matching German "z" (Zeit, Zug, Zimmer) flawlessly!',
      'sch /ʃ/': '100% Native Identity! Slovenian "Š / š" is strictly /ʃ/ (e.g. šola, šotor), matching German "sch" (Schule, schön) perfectly!',
      'tsch /tʃ/': 'Direct 1:1 match to Slovenian "Č / č" (čaj, Deutschland).',
      'ch /x/ (ach-Laut)': 'Direct match to Slovenian "H / h" (hrana, Bach, Nacht).',
      'Carinthian Border Affinity': 'Centuries of cohabitation in Austrian Carinthia and Styria foster immediate acoustic and conceptual transparency between Slovenian and Austrian German.',
    },
    this.coreA1Vocabulary = const {
      'Dober dan / Živjo': 'Hallo / Guten Tag',
      'Dobro jutro': 'Guten Morgen',
      'Dober dan': 'Guten Tag',
      'Dober večer': 'Guten Abend',
      'Hvala lepa': 'Vielen Dank',
      'Prosim': 'Bitte',
      'Da': 'Ja',
      'Ne': 'Nein',
      'Ime mi je ...': 'Mein Name ist ...',
      'Od kod ste?': 'Woher kommen Sie?',
      'Prihajam iz ...': 'Ich komme aus ...',
      'Voda': 'Wasser',
      'Kruh': 'Brot',
      'Bolnišnica': 'Krankenhaus',
      'Lekarna': 'Apotheke',
      'Železniška postaja': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'slovenian': 'Dober dan! Ali govorite nemško?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'slovenian': 'Da, trenutno se učim nemški jezik.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'slovenian': 'Prosim, kje se nahaja najbližja lekarna?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'slovenian': 'Najlepša hvala za vašo pomoč!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
