import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Pashto (پښتو / Pax̌to).
///
/// Indo-European -> Indo-Iranian -> Eastern Iranian language spoken by 50M+ people.
/// Features Perso-Arabic script with unique graphemes (ښ, ږ, څ, ځ, ټ, ډ, ړ, ڼ),
/// split ergativity in past tenses, two grammatical genders (masc/fem),
/// direct and oblique case system, and strict SOV sentence structure.
@immutable
class PashtoDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasSplitErgativity;
  final bool hasGrammaticalGender;
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const PashtoDeepLocalizationProfile({
    this.languageName = 'Pashto',
    this.autonym = 'پښتو',
    this.iso6391 = 'ps',
    this.iso6392 = 'pus',
    this.languageFamily = 'Indo-European',
    this.branch = 'Eastern Iranian',
    this.writingDirection = 'rtl',
    this.primaryScript = 'Perso-Arabic (Pashto alphabet)',
    this.specialCharacters = const ['ښ', 'ږ', 'څ', 'ځ', 'ټ', 'ډ', 'ړ', 'ڼ', 'ۍ', 'ې', 'ي', 'ى', 'ئ'],
    this.hasSplitErgativity = true,
    this.hasGrammaticalGender = true,
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'حالت فاعلي (Direct Case)': 'Subject in present tense (زه کتاب لولم). Directly maps to German Nominativ (ich lese das Buch).',
      'حالت مفعولي (Oblique Case)': 'Governed by prepositions/postpositions or past transitive subjects. Mapped to German Akkusativ & Dativ.',
      'حالت ندا (Vocative Case)': 'Used when calling or addressing entities (ای ملګری!). Mapped to German vocative/direct address.',
      'Prepositional Circumpositions': 'Pashto uses frames like "په ... کې" (in ... ke = in/inside). Directly bridges to German prepositions with Dativ (in, an, bei).',
    },
    this.culturalIslamicLexicon = const {
      'سلام': 'Friede / Begrüßung (Arabic: سلام)',
      'مننه': 'Danke / Dankbarkeit',
      'مهرباني / لطفاً': 'Bitte / Freundlichkeit (Arabic: مهرباني / لطف)',
      'کتاب': 'Buch (Arabic: كتاب)',
      'ښوونځی': 'Schule',
      'استاد': 'Lehrer / Meister (Persian: استاد)',
      'علم': 'Wissen / Wissenschaft (Arabic: علم)',
      'عدالت': 'Gerechtigkeit (Arabic: عدالة)',
      'لمونځ': 'Gebet / Salāt',
      'روژه': 'Fasten / Ramadan',
      'حلال': 'Erlaubt / Halal (Arabic: حلال)',
      'احسان': 'Güte / Wohltätigkeit (Arabic: إحسان)',
      'امانت': 'Treue / Ehrlichkeit (Arabic: أمانة)',
      'کور': 'Haus / Familie',
      'اوبه': 'Wasser',
      'ډوډۍ': 'Brot / Essen',
      'ښار': 'Stadt',
      'روغتون': 'Krankenhaus',
      'درملتون': 'Apotheke',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': 'Direct 1:1 acoustic match! German "z" (/ts/ as in Zeit, Zug) corresponds precisely to Pashto "څ" (ts).',
      'sch /ʃ/': 'Direct match to Pashto "ش" (e.g., Schule, ښار/شام).',
      'ch /x/ (ach-Laut)': 'Direct match to Pashto "خ" (e.g., Nacht, Buch, خټه).',
      'ch /ç/ (ich-Laut)': 'Front palatal fricative; contrasted with Pashto soft "ښ" and "هـ" to avoid velarization.',
      'ö /ø/ & ü /y/': 'Front rounded vowels absent in standard Pashto; mapped via lip-rounding drills from /e/ and /i/.',
      'Consonant Clusters': 'Pashto permits initial consonant clusters (e.g., پښتو, ښوونځی), greatly facilitating German onset clusters (Sprache, Straße).',
    },
    this.coreA1Vocabulary = const {
      'سلام': 'Hallo / Guten Tag',
      'سهار پخیر': 'Guten Morgen',
      'ورځ پخیر': 'Guten Tag',
      'ماښام پخیر': 'Guten Abend',
      'ډېره مننه': 'Vielen Dank',
      'مهرباني وکړئ': 'Bitte sehr',
      'هو': 'Ja',
      'نه': 'Nein',
      'زما نوم ... دی': 'Mein Name ist ...',
      'تاسو د کوم ځای یاست؟': 'Woher kommen Sie?',
      'زه له ... څخه یم': 'Ich komme aus ...',
      'اوبه': 'Wasser',
      'ډوډۍ': 'Brot',
      'روغتون': 'Krankenhaus',
      'درملتون': 'Apotheke',
      'د ریل تمځای': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'pashto': 'سلام! آیا تاسو په جرمني ژبه خبرې کوئ؟',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'pashto': 'هو، زه اوس جرمني ژبه زده کوم.',
        'german': 'Ja, ich lerne gerade Deutsch.',
        'arabic': 'نعم، أنا أتعلم الألمانية حالياً.',
      },
      {
        'pashto': 'مهرباني وکړئ، نږدې درملتون چېرته دی؟',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'pashto': 'ستاسو له مرستې څخه ډېره مننه!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Demonstrates direct phonetic bridge from Pashto 'څ' to German 'z'.
  bool hasAffricateBridgeForGermanZ() {
    return specialCharacters.contains('څ');
  }

  /// Maps case alignment string to query.
  String? getCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
