import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Danish (Dansk).
///
/// North Germanic language spoken by 6M+ people; direct land neighbor of Germany
/// (Southern Schleswig cross-border minority). Characterized by V2 word order,
/// native umlauts (æ, ø) and native 'Y/y' (/y/) matching German 'ü', the distinctive
/// stød phenomenon bridging to German glottal stops, and shared Germanic syntax.
@immutable
class DanishDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasV2WordOrder;
  final bool hasStoedPhenomenon; // Glottalization / stød
  final bool hasNativeGermanUmlauts; // æ, ø, y match German ä, ö, ü!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> borderMinorityBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const DanishDeepLocalizationProfile({
    this.languageName = 'Danish',
    this.autonym = 'Dansk',
    this.iso6391 = 'da',
    this.iso6392 = 'dan',
    this.languageFamily = 'Indo-European',
    this.branch = 'Germanic (North Germanic / East Scandinavian)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Danish alphabet)',
    this.specialCharacters = const ['æ', 'ø', 'å'],
    this.hasV2WordOrder = true,
    this.hasStoedPhenomenon = true,
    this.hasNativeGermanUmlauts = true, // æ, ø, y = ä, ö, ü!
    this.wordOrder = 'V2 (main) / SVO (subordinate)',
    this.genderEquivalenceMap = const {
      'Fælleskøn (en-ord)': 'German Maskulinum (der) & Femininum (die) - e.g., en hund (der Hund), en kvinde (die Frau).',
      'Intetkøn (et-ord)': 'German Neutrum (das) - e.g., et hus (das Haus), et barn (das Kind).',
    },
    this.borderMinorityBridge = const {
      'Slesvig Cross-Border Affinity': 'Historical Danish minority in Southern Schleswig (Germany) and German minority in Northern Schleswig (Denmark) foster deep bilingual pedagogical frameworks.',
      'Article System Mapping': 'Postposed suffix in simple definites (bogen = das Buch), preposed article in complex definites (den store bog = das große Buch).',
    },
    this.culturalIslamicLexicon = const {
      'hej / goddag / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'tak / mange tak': 'Danke / Vielen Dank',
      'vær så venlig / velbekomme': 'Bitte / Gern geschehen',
      'bog': 'Buch',
      'skole / madrassa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'lærer': 'Lehrer / Dozent',
      'viden / videnskab': 'Wissen / Wissenschaft',
      'retfærdighed': 'Gerechtigkeit',
      'bøn / salat': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'ven': 'Freund',
      'vand': 'Wasser',
      'brød': 'Brot / Nahrung',
      'hus / hjem': 'Haus / Heim',
      'by': 'Stadt',
      'hospital / sygehus': 'Krankenhaus',
      'apotek': 'Apotheke',
      'moské': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'ö /ø/': '100% Native Identity! Danish "Ø / ø" (dør, grøn) matches German "ö" (schön, grün) with zero acoustic distortion!',
      'ä /ɛ/': '100% Native Identity! Danish "Æ / æ" (lære, æble) matches German "ä" (Männer, Äpfel) flawlessly!',
      'ü /y/': '100% Native Identity! Danish "Y / y" is phonetically /y/ (by, lytte), matching German "ü" (über, fünf) directly!',
      'sch /ʃ/': 'Direct 1:1 match to Danish "Sj / sj" (sjus, sjæl, Schule, schön).',
      'Stød & Knacklaut Bridge': 'Danish native stød (glottal catch) gives learners natural muscular intuition for pronouncing German glottal stops before vowel-initial words (Verein [fɛɐ̯ˈʔaɪn], Theater [teˈʔaːtɐ]).',
    },
    this.coreA1Vocabulary = const {
      'Hej / Goddag': 'Hallo / Guten Tag',
      'Godmorgen': 'Guten Morgen',
      'Godeftermiddag': 'Guten Tag',
      'Godaften': 'Guten Abend',
      'Mange tak': 'Vielen Dank',
      'Vær så venlig': 'Bitte',
      'Ja': 'Ja',
      'Nej': 'Nein',
      'Jeg hedder ...': 'Mein Name ist ...',
      'Hvor kommer du fra?': 'Woher kommen Sie?',
      'Jeg kommer fra ...': 'Ich komme aus ...',
      'Vand': 'Wasser',
      'Brød': 'Brot',
      'Hospital': 'Krankenhaus',
      'Apotek': 'Apotheke',
      'Banegård': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'danish': 'Hej! Taler du tysk?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'danish': 'Ja, jeg lærer tysk lige nu.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'danish': 'Undskyld, hvor ligger det nærmeste apotek?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'danish': 'Mange tak for din hjælp!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Danish gender to its German article category.
  String? getGermanGenderBridge(String genderCategory) {
    for (final entry in genderEquivalenceMap.entries) {
      if (entry.key.toLowerCase().contains(genderCategory.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
