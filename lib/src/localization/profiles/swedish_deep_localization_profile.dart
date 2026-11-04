import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Swedish (Svenska).
///
/// North Germanic language spoken by 10.5M+ people in Sweden and Finland.
/// Characterized by V2 word order in main clauses, native umlauts (ä, ö) and native
/// 'Y/y' (/y/) matching German 'ü' exactly, tonal pitch accents, double definiteness
/// bridging to German adjective declensions, and shared Germanic core vocabulary.
@immutable
class SwedishDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasV2WordOrder; // V2 in main clauses!
  final bool hasNativeGermanUmlauts; // ä, ö, y match German ä, ö, ü!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> doubleDefinitenessBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const SwedishDeepLocalizationProfile({
    this.languageName = 'Swedish',
    this.autonym = 'Svenska',
    this.iso6391 = 'sv',
    this.iso6392 = 'swe',
    this.languageFamily = 'Indo-European',
    this.branch = 'Germanic (North Germanic / East Scandinavian)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Swedish alphabet)',
    this.specialCharacters = const ['å', 'ä', 'ö'],
    this.hasV2WordOrder = true,
    this.hasNativeGermanUmlauts = true, // ä, ö, y = ä, ö, ü!
    this.wordOrder = 'V2 (main) / SVO (subordinate)',
    this.genderEquivalenceMap = const {
      'Utrum / Reale (en-ord)': 'German Maskulinum (der) & Femininum (die) - e.g., en hund (der Hund), en kvinna (die Frau).',
      'Neutrum (ett-ord)': 'German Neutrum (das) - e.g., ett hus (das Haus), ett barn (das Kind).',
    },
    this.doubleDefinitenessBridge = const {
      'Dubbel bestämdhet (den stora boken)': 'Preposed article + adjective + suffixed noun. Directly maps to German weak adjective declension: das große Buch / die große Frau.',
      'Obestämd form (en stor bok)': 'Indefinite article + adjective + noun. Directly maps to German mixed adjective declension: ein großes Buch.',
    },
    this.culturalIslamicLexicon = const {
      'hej / hejsan / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'tack / tack så mycket': 'Danke / Vielen Dank',
      'varsågod': 'Bitte / Gern geschehen',
      'bok': 'Buch',
      'skola / madrassa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'lärare': 'Lehrer / Dozent',
      'kunskap / vetenskap': 'Wissen / Wissenschaft',
      'rättvisa': 'Gerechtigkeit',
      'bön / salat': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'vän': 'Freund',
      'vatten': 'Wasser',
      'bröd': 'Brot / Nahrung',
      'hus / hem': 'Haus / Heim',
      'stad': 'Stadt',
      'sjukhus': 'Krankenhaus',
      'apotek': 'Apotheke',
      'moské': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'ä /ɛ/ & ö /ø/': '100% Native Identity! Swedish "ä" (äpple, häst) and "ö" (öga, röd) match German "ä" and "ö" (Äpfel, schön) with absolute acoustic perfection!',
      'ü /y/': '100% Native Identity! Swedish "Y / y" is phonetically /y/ (e.g. yxa, fyra), matching German "ü" (über, fünf, Tür) flawlessly!',
      'z /ts/': 'Swedish "z" is pronounced /s/; German "z" is an affricate /ts/, practiced as the compound sequence "t+s" (tsunami -> Zeit).',
      'sch /ʃ/': 'Swedish sj-sound (/ɧ/ or /ʂ/) is contrasted with German standard postalveolar /ʃ/ (Schule, schön).',
      'V2 Acceleration Bridge': 'Swedish learners master German sentence structure almost immediately because both languages strictly enforce the Verb-Second (V2) rule in main clauses (Idag läser jag = Heute lese ich).',
    },
    this.coreA1Vocabulary = const {
      'Hej / God dag': 'Hallo / Guten Tag',
      'God morgon': 'Guten Morgen',
      'God eftermiddag': 'Guten Tag',
      'God kväll': 'Guten Abend',
      'Tack så mycket': 'Vielen Dank',
      'Varsågod': 'Bitte',
      'Ja': 'Ja',
      'Nej': 'Nein',
      'Jag heter ...': 'Mein Name ist ...',
      'Varifrån kommer du?': 'Woher kommen Sie?',
      'Jag kommer från ...': 'Ich komme aus ...',
      'Vatten': 'Wasser',
      'Bröd': 'Brot',
      'Sjukhus': 'Krankenhaus',
      'Apotek': 'Apotheke',
      'Tågstation': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'swedish': 'Hej! Talar du tyska?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'swedish': 'Ja, jag lär mig tyska just nu.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'swedish': 'Ursäkta, var ligger närmaste apotek?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'swedish': 'Tack så mycket för hjälpen!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Swedish gender to its German article category.
  String? getGermanGenderBridge(String genderCategory) {
    for (final entry in genderEquivalenceMap.entries) {
      if (entry.key.toLowerCase().contains(genderCategory.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
