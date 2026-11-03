import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Estonian (Eesti keel).
///
/// Finnic language spoken by 1.1M+ people. Uniquely features a massive historical
/// Baltic German Hanseatic lexical substrate (over 20% of vocabulary is Germanic!),
/// native triple umlauts (ä, ö, ü), three phonemic length degrees (lühike, pikk, ülipikk),
/// 14 grammatical cases, and loss of vowel harmony easing German vocabulary acquisition.
@immutable
class EstonianDeepLocalizationProfile {
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
  final bool hasHanseaticGermanSubstrate; // 20%+ direct German loanwords!
  final bool hasNativeGermanUmlauts; // ä, ö, ü are all native!
  final String wordOrder;
  final Map<String, String> hanseaticCognateBridges;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const EstonianDeepLocalizationProfile({
    this.languageName = 'Estonian',
    this.autonym = 'Eesti keel',
    this.iso6391 = 'et',
    this.iso6392 = 'est',
    this.languageFamily = 'Uralic',
    this.branch = 'Finnic',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Estonian alphabet)',
    this.specialCharacters = const ['ä', 'ö', 'ü', 'õ', 'š', 'ž'],
    this.isAgglutinative = true,
    this.hasHanseaticGermanSubstrate = true,
    this.hasNativeGermanUmlauts = true, // ä, ö, ü all native!
    this.wordOrder = 'SVO / V2 tendency',
    this.hanseaticCognateBridges = const {
      'arst': 'German "Arzt" (Physician / Doctor).',
      'kool': 'German "Schule" (School - Low German Schole).',
      'müts': 'German "Mütze" (Cap / Beanie).',
      'loss': 'German "Schloss" (Castle / Palace).',
      'trepp': 'German "Treppe" (Staircase).',
      'reis': 'German "Reise" (Journey / Trip).',
      'klaas': 'German "Glas" (Glass).',
      'proua': 'German "Frau" (Mrs. / Lady - Low German Fru).',
      'härra': 'German "Herr" (Mr. / Gentleman).',
      'turg': 'German "Markt" (Market - via Old East Slavic/Germanic).',
    },
    this.caseSystemAlignment = const {
      '1. Nimetav (Nominativ)': 'Base subject form (raamat). Maps to German Nominativ (das Buch).',
      '2. Omastav (Genitiv - -)': 'Stem vowel/form (raamatu). Maps to German Genitiv (des Buches).',
      '3. Osastav (Partitiv - -t/-d)': 'Partitive/indefinite object (raamatut). Maps to German indefinite Akkusativ.',
      '4. Sisseütlev (Illativ - -sse)': 'Direction into. Maps to German Akkusativ with directional preposition "in".',
      '5. Seesütlev (Inessiv - -s)': 'Location inside. Maps to German Dativ with static preposition "in".',
      '6. Seestütlev (Elativ - -st)': 'Source out of. Maps to German Dativ with preposition "aus".',
      '7. Pealeütlev (Allativ - -le)': 'Direction to surface/person. Maps to German Dativ with preposition "zu".',
      '8. Pealütlev (Adessiv - -l)': 'Location on/at or means. Maps to German Dativ with prepositions "auf" and "an".',
      '9. Pealtütlev (Ablativ - -lt)': 'Direction from surface. Maps to German Dativ with preposition "von".',
      '10. Saav (Translativ - -ks)': 'Change of state. Maps to German "zu / werden".',
      '11. Rajav (Terminativ - -ni)': 'Spatial/temporal limit. Maps to German "bis / bis zu".',
      '12. Olev (Essiv - -na)': 'State of being (arstina). Maps to German "als" (als Arzt).',
      '13. Ilmaütlev (Abessiv - -ta)': 'Without suffix (rahata). Maps to German preposition "ohne".',
      '14. Kaasaütlev (Komitativ - -ga)': 'Accompaniment or instrument. Maps to German Dativ with preposition "mit".',
    },
    this.culturalIslamicLexicon = const {
      'tere / päevast / salam': 'Hallo / Guten Tag / Friede (Arabic: سلام)',
      'aitäh / tänan väga': 'Danke / Vielen Dank',
      'palun': 'Bitte / Gern geschehen',
      'raamat': 'Buch',
      'kool': 'Schule (German loan: Schule)',
      'õpetaja': 'Lehrer / Lehrerin',
      'teadmine / teadus': 'Wissen / Wissenschaft',
      'õiglus': 'Gerechtigkeit',
      'palvus / namaz': 'Gebet / Salāt (Persian: نماز)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'sõber': 'Freund',
      'vesi': 'Wasser',
      'leib': 'Brot / Nahrung',
      'maja / kodu': 'Haus / Heim',
      'linn': 'Stadt',
      'haigla': 'Krankenhaus',
      'apteek': 'Apotheke (German loan: Apotheke)',
      'mošee': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'ä, ö, ü': '100% Native Triad! Estonian natively possesses all three German umlauts: "ä" (käsi), "ö" (öö), and "ü" (süda), matching German "ä", "ö", "ü" flawlessly!',
      'z /ts/': '100% Native Identity! Estonian compound "Ts / ts" is strictly /ts/ (tsirkus), matching German "z" (Zeit, Zimmer) perfectly!',
      'sch /ʃ/': 'Direct match to Estonian "Š / š" (šokolaad, Schule).',
      'Hanseatic Lexical Advantage': 'Estonian learners enjoy the highest lexical transparency in the Uralic family due to hundreds of shared everyday German loanwords.',
    },
    this.coreA1Vocabulary = const {
      'Tere / Tere päevast': 'Hallo / Guten Tag',
      'Tere hommikust': 'Guten Morgen',
      'Tere päevast': 'Guten Tag',
      'Tere õhtust': 'Guten Abend',
      'Suur aitäh': 'Vielen Dank',
      'Palun': 'Bitte',
      'Jah': 'Ja',
      'Ei': 'Nein',
      'Minu nimi on ...': 'Mein Name ist ...',
      'Kust te pärit olete?': 'Woher kommen Sie?',
      'Ma olen pärit ...-st': 'Ich komme aus ...',
      'Vesi': 'Wasser',
      'Leib': 'Brot',
      'Haigla': 'Krankenhaus',
      'Apteek': 'Apotheke',
      'Raudteejaam': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'estonian': 'Tere päevast! Kas te räägite saksa keelt?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'estonian': 'Jah, ma õpin praegu saksa keelt.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'estonian': 'Palun öelge, kus asub lähim apteek?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'estonian': 'Suur aitäh teie abi eest!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates an Estonian case suffix into its German prepositional/case equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
