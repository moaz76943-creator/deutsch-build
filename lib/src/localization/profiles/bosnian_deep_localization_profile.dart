import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Bosnian (Bosanski jezik).
///
/// South Slavic language spoken by 3.5M+ people in Bosnia and Herzegovina, Sandžak,
/// and diaspora across Germany and Austria. Characterized by a 3-gender system matching
/// German der/die/das exactly, a 7-case declension framework that simplifies German
/// case mastery, exact 1:1 match of letter "C/c" to German "Z/z" (/ts/), and rich
/// Ottoman/Islamic cultural vocabulary (turcizmi).
@immutable
class BosnianDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasThreeGenders; // Muški, Ženski, Srednji matching German der, die, das!
  final bool hasNativeGermanZSound; // Bosnian 'c' = German 'z' (/ts/)!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const BosnianDeepLocalizationProfile({
    this.languageName = 'Bosnian',
    this.autonym = 'Bosanski jezik',
    this.iso6391 = 'bs',
    this.iso6392 = 'bos',
    this.languageFamily = 'Indo-European',
    this.branch = 'South Slavic (Western)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Gaj\'s alphabet)',
    this.specialCharacters = const ['č', 'ć', 'dž', 'đ', 'š', 'ž'],
    this.hasThreeGenders = true,
    this.hasNativeGermanZSound = true, // 'c' is strictly /ts/
    this.wordOrder = 'SVO',
    this.genderEquivalenceMap = const {
      'Muški rod (Masculin)': 'German Maskulinum (der) - e.g., čovjek (der Mann), grad (die Stadt/masc).',
      'Ženski rod (Feminin)': 'German Femininum (die) - e.g., žena (die Frau), knjiga (das Buch/fem).',
      'Srednji rod (Neutrum)': 'German Neutrum (das) - e.g., dijete (das Kind), selo (das Dorf).',
    },
    this.caseSystemAlignment = const {
      '1. Nominativ (Ko? Šta?)': 'Direct subject. Direct 1:1 match to German Nominativ (Wer? Was? - der Mann).',
      '2. Genitiv (Koga? Čega?)': 'Possession and partitive. Direct match to German Genitiv (Wessen? - des Mannes).',
      '3. Dativ (Kome? Čemu?)': 'Indirect object / direction. Direct match to German Dativ (Wem? - dem Mann).',
      '4. Akkusativ (Koga? Šta?)': 'Direct object. Direct match to German Akkusativ (Wen? Was? - den Mann).',
      '5. Vokativ (Hej!)': 'Direct address (Prijatelju!). Maps to German direct address.',
      '6. Instrumental (S kim? Čim?)': 'Accompaniment or means. Directly maps to German Dativ with preposition "mit".',
      '7. Lokativ (O kome? O čemu?)': 'Location and topic. Directly maps to German Dativ with prepositions "in", "an", "über".',
    },
    this.culturalIslamicLexicon = const {
      'selam / dobar dan': 'Friede / Begrüßung (Arabic: سلام)',
      'hvala / šukran': 'Danke / Dankbarkeit (Arabic: شكراً)',
      'molim / izvolite': 'Bitte',
      'knjiga / ćitap': 'Buch (Arabic: كتاب)',
      'škola / medresa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'učitelj / muderris': 'Lehrer (Arabic: مدرس)',
      'znanje / ilum': 'Wissen / Wissenschaft (Arabic: علم)',
      'pravda / adalet': 'Gerechtigkeit (Arabic: عدالة)',
      'namaz / salavat': 'Gebet / Salāt (Persian/Arabic: نماز / صلوات)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'prijatelj / dost': 'Freund (Persian: دوست)',
      'voda': 'Wasser',
      'hljeb / somun': 'Brot / Fladenbrot',
      'kuća': 'Haus / Heim',
      'grad / šeher': 'Stadt (Persian: شهر)',
      'bolnica': 'Krankenhaus',
      'apoteka': 'Apotheke',
      'džamija': 'Moschee (Arabic: جامع)',
      'sabur': 'Geduld / Ausdauer (Arabic: صبر)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Bosnian "C / c" is universally pronounced as /ts/ (e.g. cura, car, centar), matching German "z" (Zeit, Zug, Zimmer) flawlessly!',
      'sch /ʃ/': 'Direct 1:1 match to Bosnian "Š / š" (škola, šuma, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Bosnian "Č / č" and "Ć / ć" (čaša, ćevap, Deutschland).',
      'ch /x/ (ach-Laut)': 'Direct match to Bosnian "H / h" (lahko, hrana, Bach, Nacht).',
      '7-Case Mastery': 'Bosnian learners naturally operate a 7-case framework, making German\'s 4-case system straightforward and highly intuitive.',
    },
    this.coreA1Vocabulary = const {
      'Dobar dan / Selam': 'Hallo / Guten Tag',
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
      'Hljeb': 'Brot',
      'Bolnica': 'Krankenhaus',
      'Apoteka': 'Apotheke',
      'Željeznička stanica': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'bosnian': 'Dobar dan! Da li govorite njemački?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'bosnian': 'Da, trenutno učim njemački jezik.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'bosnian': 'Molim vas, gdje se nalazi najbliža apoteka?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'bosnian': 'Mnogo vam hvala na pomoći!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Bosnian case to its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
