import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Hausa (Harshen Hausa).
///
/// Afroasiatic language family (West Chadic branch) spoken by 85M+ people
/// across Nigeria, Niger, Ghana, Cameroon, Chad, and Sudan.
/// Features tonal distinctions, hooked letters (ɓ, ɗ, ƙ, ƴ), rich Arabic-Islamic
/// loanword history, and SVO syntax contrasting with German V2/SOV structures.
@immutable
class HausaDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasTones;
  final bool hasGrammaticalGender;
  final String wordOrder;
  final Map<String, String> commonArabicLoanwords;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> grammaticalCaseMapping;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const HausaDeepLocalizationProfile({
    this.languageName = 'Hausa',
    this.autonym = 'Harshen Hausa',
    this.iso6391 = 'ha',
    this.iso6392 = 'hau',
    this.languageFamily = 'Afroasiatic',
    this.branch = 'West Chadic',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Boko) / Ajami',
    this.specialCharacters = const ['ɓ', 'ɗ', 'ƙ', 'ƴ', "'y", 'R̃', 'r̃'],
    this.hasTones = true,
    this.hasGrammaticalGender = true,
    this.wordOrder = 'SVO',
    this.commonArabicLoanwords = const {
      'addu\'a': 'Dua / Bittgebet (Arabic: دعاء)',
      'darasi': 'Lektion / Unterricht (Arabic: درس)',
      'alkali': 'Richter (Arabic: القاضي)',
      'littafi': 'Buch (Arabic: الكتاب)',
      'lokaci': 'Zeit (Arabic: الوقت)',
      'albasa': 'Zwiebel (Arabic: البصل)',
      'hakkoki': 'Rechte (Arabic: حقوق)',
      'salla': 'Gebet / Salāt (Arabic: صلاة)',
      'asibiti': 'Krankenhaus (Latin hospital)',
      'malami': 'Lehrer (Arabic: معلم)',
      'duniyar': 'Welt (Arabic: دنيا)',
      'labari': 'Nachricht (Arabic: خبر)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'haram': 'Verboten / Haram (Arabic: حرام)',
      'sadaka': 'Almosen / Spende (Arabic: صدقة)',
      'amana': 'Vertrauenswürdigkeit (Arabic: أمانة)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Corresponds directly to Hausa "sh" (e.g., shayi, Schule).',
      'ch /ç/': 'Requires front tongue elevation; contrasted with Hausa "h" and "k".',
      'ch /x/': 'Similar to Hausa velar/uvular sounds in Arabic loanwords (e.g., halin).',
      'ö /ø/ & ü /y/': 'Front rounded vowels absent in standard Hausa; mapped via /e/ -> /ø/ and /i/ -> /y/ rounding drills.',
      'z /ts/': 'German "z" is pronounced /ts/; contrasted with Hausa "ts" (ejective dental/alveolar affricate).',
      'r /ʁ/': 'German uvular "r" contrasted with Hausa flap /ɾ/ and trill /r̃/.',
    },
    this.grammaticalCaseMapping = const {
      'Nominativ': 'Subject position in SVO (Hausa uses subject pronouns like "na", "ya", "ta").',
      'Akkusativ': 'Direct object following the verb (marked by word order without noun inflection).',
      'Dativ': 'Indirect object preceded by preposition "wa" or "ma-" (e.g., ya ba ni = er gab mir).',
      'Genitiv': 'Construct state or associative particle "-n" (masc.) / "-r" (fem.) (e.g., gidan mutum = das Haus des Mannes).',
    },
    this.coreA1Vocabulary = const {
      'Sannu': 'Hallo / Guten Tag',
      'Ina kwana?': 'Guten Morgen (Wie hast du geschlafen?)',
      'Ina wuni?': 'Guten Tag (Wie war dein Tag?)',
      'Na gode': 'Danke',
      'Don Allah': 'Bitte',
      'I / E': 'Ja',
      'A\'a': 'Nein',
      'Lafiya lau': 'Sehr gut / Im Frieden',
      'Sunana': 'Mein Name ist',
      'Daga ina kake?': 'Woher kommst du? (zu einem Mann)',
      'Daga ina kike?': 'Woher kommst du? (zu einer Frau)',
      'Ni daga ... nake': 'Ich komme aus ...',
      'Gida': 'Haus',
      'Ruwa': 'Wasser',
      'Abinci': 'Essen / Nahrung',
      'Birni': 'Stadt',
      'Kasuwa': 'Markt',
      'Masallaci': 'Moschee',
      'Aiki': 'Arbeit',
    },
    this.practicalDialoguePhrases = const [
      {
        'hausa': 'Sannu, yaya sunanka?',
        'german': 'Hallo, wie heißt du?',
        'arabic': 'مرحباً، ما اسمك؟',
      },
      {
        'hausa': 'Sunana Ibrahim, ina koyon harshen Jamusanci.',
        'german': 'Mein Name ist Ibrahim, ich lerne Deutsch.',
        'arabic': 'اسمي إبراهيم، أنا أتعلم اللغة الألمانية.',
      },
      {
        'hausa': 'Ina neman tashar jirgin kasa.',
        'german': 'Ich suche den Bahnhof.',
        'arabic': 'أنا أبحث عن محطة القطار.',
      },
      {
        'hausa': 'Wannan abincin halal ne?',
        'german': 'Ist dieses Essen halal / erlaubt?',
        'arabic': 'هل هذا الطعام حلال؟',
      },
    ],
  });

  /// Validates phonetic bridge rule for German sounds.
  bool containsPhoneticBridge(String soundPattern) {
    return germanPhoneticBridges.keys.any((key) => key.contains(soundPattern));
  }

  /// Looks up German equivalent for core Hausa vocabulary.
  String? translateToGerman(String hausaWord) {
    return coreA1Vocabulary[hausaWord];
  }

  /// Checks if a word is an identified Arabic loanword in Hausa.
  bool isArabicLoanword(String word) {
    final clean = word.toLowerCase().trim();
    return commonArabicLoanwords.containsKey(clean);
  }
}
