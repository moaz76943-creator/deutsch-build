import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Norwegian (Norsk - Bokmål & Nynorsk).
///
/// North Germanic language spoken by 5.5M+ people in Norway. Features preservation of
/// all 3 grammatical genders (hankjønn, hunkjønn, intetkjønn) matching German der, die, das
/// 1:1, V2 word order in main clauses, native 'ø' and 'æ' matching German 'ö' and 'ä',
/// native 'y' matching German 'ü', tonal pitch accents, and exact match of 'skj/sj' to 'sch'.
@immutable
class NorwegianDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final List<String> supportedStandards; // Bokmål & Nynorsk
  final List<String> specialCharacters;
  final bool hasThreeGenders; // Exact match to German der, die, das!
  final bool hasV2WordOrder;
  final bool hasNativeGermanUmlauts; // æ, ø, y match German ä, ö, ü!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const NorwegianDeepLocalizationProfile({
    this.languageName = 'Norwegian',
    this.autonym = 'Norsk',
    this.iso6391 = 'no',
    this.iso6392 = 'nor',
    this.languageFamily = 'Indo-European',
    this.branch = 'Germanic (North Germanic / West Scandinavian)',
    this.writingDirection = 'ltr',
    this.supportedStandards = const ['Bokmål (nob)', 'Nynorsk (nno)'],
    this.specialCharacters = const ['æ', 'ø', 'å'],
    this.hasThreeGenders = true, // hankjønn, hunkjønn, intetkjønn!
    this.hasV2WordOrder = true,
    this.hasNativeGermanUmlauts = true, // æ, ø, y = ä, ö, ü!
    this.wordOrder = 'V2 (main) / SVO (subordinate)',
    this.genderEquivalenceMap = const {
      'Hankjønn (en)': 'German Maskulinum (der) - e.g., en mann (der Mann), en stol (der Stuhl).',
      'Hunkjønn (ei)': 'German Femininum (die) - e.g., ei kvinne / boka (die Frau, die Schule).',
      'Intetkjønn (et)': 'German Neutrum (das) - e.g., et hus (das Haus), et barn (das Kind).',
    },
    this.culturalIslamicLexicon = const {
      'hei / god dag / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'takk / tusen takk': 'Danke / Vielen Dank',
      'vær så god': 'Bitte / Gern geschehen',
      'bok': 'Buch',
      'skole / madrassa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'lærer': 'Lehrer / Dozent',
      'kunnskap / vitenskap': 'Wissen / Wissenschaft',
      'rettferdighet': 'Gerechtigkeit',
      'bønn / salat': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'venn': 'Freund',
      'vann': 'Wasser',
      'brød': 'Brot / Nahrung',
      'hus / hjem': 'Haus / Heim',
      'by': 'Stadt',
      'sykehus': 'Krankenhaus',
      'apotek': 'Apotheke',
      'moské': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'ö /ø/': '100% Native Identity! Norwegian "Ø / ø" (dør, sønn, grønn) matches German "ö" (schön, grün) with zero distortion!',
      'ä /ɛ/': '100% Native Identity! Norwegian "Æ / æ" (lære, bære, være) matches German "ä" (Männer, Äpfel) flawlessly!',
      'ü /y/': '100% Native Identity! Norwegian "Y / y" is phonemically /y/ (lys, by, ny), matching German "ü" (über, Tür) directly!',
      'sch /ʃ/': '100% Native Identity! Norwegian "Skj / skj" and "Sj / sj" (skjorte, sjel, sjiraff) are strictly /ʃ/, matching German "sch" (Schule, schön) perfectly!',
      '3-Gender Structural Parallel': 'Norwegian naturally operates 3 grammatical genders (en/ei/et), providing learners with an instant intuitive framework for German der, die, das.',
    },
    this.coreA1Vocabulary = const {
      'Hei / God dag': 'Hallo / Guten Tag',
      'God morgen': 'Guten Morgen',
      'God ettermiddag': 'Guten Tag',
      'God kveld': 'Guten Abend',
      'Tusen takk': 'Vielen Dank',
      'Vær så god': 'Bitte',
      'Ja': 'Ja',
      'Nei': 'Nein',
      'Jeg heter ...': 'Mein Name ist ...',
      'Hvor kommer du fra?': 'Woher kommen Sie?',
      'Jeg kommer fra ...': 'Ich komme aus ...',
      'Vann': 'Wasser',
      'Brød': 'Brot',
      'Sykehus': 'Krankenhaus',
      'Apotek': 'Apotheke',
      'Togstasjon': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'norwegian': 'Hei! Snakker du tysk?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'norwegian': 'Ja, jeg lærer tysk akkurat nå.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'norwegian': 'Unnskyld, hvor er det nærmeste apoteket?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'norwegian': 'Tusen takk for hjelpen!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Norwegian gender to its German article category.
  String? getGermanGenderBridge(String genderCategory) {
    for (final entry in genderEquivalenceMap.entries) {
      if (entry.key.toLowerCase().contains(genderCategory.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
