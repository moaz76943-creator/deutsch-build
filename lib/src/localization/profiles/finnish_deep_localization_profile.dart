import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Finnish (Suomen kieli / Suomi).
///
/// Uralic language (Finnic branch) spoken by 5.5M+ people. Characterized by
/// 15 grammatical cases, consonant gradation (astevaihtelu), strict vowel harmony,
/// native umlauts (ä, ö) and native 'Y/y' (/y/) matching German 'ü' exactly,
/// strict phonemic quantity (sound length), and lack of grammatical gender.
@immutable
class FinnishDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool isAgglutinative;
  final bool hasVowelHarmony;
  final bool hasConsonantGradation;
  final bool hasNativeGermanUmlauts; // ä, ö, y match German ä, ö, ü!
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const FinnishDeepLocalizationProfile({
    this.languageName = 'Finnish',
    this.autonym = 'Suomi',
    this.iso6391 = 'fi',
    this.iso6392 = 'fin',
    this.languageFamily = 'Uralic',
    this.branch = 'Finnic',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Finnish alphabet)',
    this.specialCharacters = const ['ä', 'ö', 'y', 'å'],
    this.isAgglutinative = true,
    this.hasVowelHarmony = true,
    this.hasConsonantGradation = true,
    this.hasNativeGermanUmlauts = true, // ä, ö, y = ä, ö, ü!
    this.wordOrder = 'SVO',
    this.caseSystemAlignment = const {
      '1. Nominatiivi (Perusmuoto)': 'Base subject form (kirja). Maps to German Nominativ (das Buch).',
      '2. Genetiivi (-n)': 'Possession and relations (kirjan). Maps to German Genitiv (des Buches).',
      '3. Partitiivi (-a / -ä / -ta / -tä)': 'Partitive/indefinite object (kirjaa). Maps to German indefinite Akkusativ.',
      '4. Akkusatiivi (-n / perusmuoto)': 'Complete direct object. Maps to German definite Akkusativ (den Mann).',
      '5. Inessiivi (-ssa / -ssä - sisällä)': 'Location inside. Maps to German Dativ with static preposition "in".',
      '6. Elatiivi (-sta / -stä - sisältä)': 'Source out of. Maps to German Dativ with preposition "aus".',
      '7. Illatiivi (-Vn / -hVn - sisään)': 'Direction into. Maps to German Akkusativ with directional preposition "in".',
      '8. Adessiivi (-lla / -llä - päällä/avulla)': 'Location on/at or means. Maps to German Dativ with "auf", "an", "mit".',
      '9. Ablatiivi (-lta / -ltä - päältä)': 'Direction away from surface. Maps to German Dativ with preposition "von".',
      '10. Allatiivi (-lle - päälle/luo)': 'Direction to surface/person. Maps to German Dativ with preposition "zu".',
      '11. Essiivi (-na / -nä - jonakin)': 'State of being (opettajana). Maps to German preposition "als" (als Lehrer).',
      '12. Translatiivi (-ksi - joksikin)': 'Change of state. Maps to German "zu / werden" (wird zum Lehrer).',
      '13. Abessiivi (-tta / -ttä - ilman)': 'Without suffix (rahatta). Maps to German preposition "ohne" (ohne Geld).',
    },
    this.culturalIslamicLexicon = const {
      'hei / päivää / salam': 'Hallo / Guten Tag / Friede (Arabic: سلام)',
      'kiitos / paljon kiitoksia': 'Danke / Vielen Dank',
      'ole hyvä': 'Bitte / Gern geschehen',
      'kirja': 'Buch',
      'koulu / madrassa': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'opettaja': 'Lehrer / Lehrerin',
      'tieto / tiede': 'Wissen / Wissenschaft',
      'oikeudenmukaisuus': 'Gerechtigkeit',
      'rukous / namaz': 'Gebet / Salāt (Persian: نماز)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'ystävä': 'Freund',
      'vesi': 'Wasser',
      'leipä': 'Brot / Nahrung',
      'talo / koti': 'Haus / Heim',
      'kaupunki': 'Stadt',
      'sairaala': 'Krankenhaus',
      'apteekki': 'Apotheke',
      'moskeija': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'ä /ɛ/ & ö /ø/': '100% Native Identity! Finnish "ä" (äiti, päivä) and "ö" (yö, pöytä) match German "ä" and "ö" directly!',
      'ü /y/': '100% Native Identity! Finnish "Y / y" is phonemically a close front rounded vowel /y/ (yksi, kynä), matching German "ü" (über, fünf, Tür) flawlessly!',
      'z /ts/': 'Finnish lacks native affricates; German "z" is practiced as the compound sequence "t+s" (Zeit -> Tsait).',
      'sch /ʃ/': 'Practiced with postalveolar retraction contrasting with Finnish alveolar /s/ (šokki -> Schule).',
      'Phonemic Quantity Bridge': 'Finnish distinction between short and long sounds (tuli / tuuli / tulli) directly trains learners to master German vowel quantity contrasts (Bann / Bahn, Stadt / Staat).',
    },
    this.coreA1Vocabulary = const {
      'Hei / Hyvää päivää': 'Hallo / Guten Tag',
      'Hyvää huomenta': 'Guten Morgen',
      'Hyvää päivää': 'Guten Tag',
      'Hyvää iltaa': 'Guten Abend',
      'Paljon kiitoksia': 'Vielen Dank',
      'Ole hyvä': 'Bitte',
      'Kyllä / Joo': 'Ja',
      'Ei': 'Nein',
      'Nimeni on ...': 'Mein Name ist ...',
      'Mistä olet kotoisin?': 'Woher kommen Sie?',
      'Olen kotoisin ...-sta/stä': 'Ich komme aus ...',
      'Vesi': 'Wasser',
      'Leipä': 'Brot',
      'Sairaala': 'Krankenhaus',
      'Apteekki': 'Apotheke',
      'Rautatieasema': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'finnish': 'Hyvää päivää! Puhutteko saksaa?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'finnish': 'Kyllä, opiskelen tällä hetkellä saksan kieltä.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'finnish': 'Anteeksi, missä on lähin apteekki?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'finnish': 'Paljon kiitoksia avustanne!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Finnish case suffix into its German prepositional/case equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
