import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Malayalam (മലയാളം).
///
/// Southern Dravidian language spoken by 38M+ people in Kerala and Gulf diaspora.
/// Characterized by absence of personal verb inflections (contrasting with German
/// person/number verb agreement), pure consonant coda Chillu letters (ൺ, ൻ, ർ, ൽ, ൾ),
/// agglutinative 7-case morphology, and SOV clause architecture.
@immutable
class MalayalamDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> chilluLetters;
  final bool hasPersonalVerbInflections; // false in Malayalam - key German bridge!
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const MalayalamDeepLocalizationProfile({
    this.languageName = 'Malayalam',
    this.autonym = 'മലയാളം',
    this.iso6391 = 'ml',
    this.iso6392 = 'mal',
    this.languageFamily = 'Dravidian',
    this.branch = 'Southern Dravidian',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Malayalam script',
    this.chilluLetters = const ['ൺ', 'ൻ', 'ർ', 'ൽ', 'ൾ', 'ൿ'],
    this.hasPersonalVerbInflections = false, // Critical pedagogical contrast
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'Prathama (പ്രഥമ - Nominativ)': 'Base subject form. Matches German Nominativ (der Mann liest).',
      'Dvitiya (ദ്വിതീയ - എ - Akkusativ)': 'Accusative suffix -e (പുസ്തകത്തെ / അവനെ). Matches German Akkusativ (den Mann).',
      'Tritiya (തൃതീയ - ആൽ - Instrumentalis)': 'Instrumental suffix -āl. Matches German Dativ with preposition "mit".',
      'Chaturthi (ചതുർത്ഥി - ക്ക്/ന് - Dativ)': 'Dative suffix -kku/-nu (സ്കൂളിലേക്ക്). Matches German Dativ and direction prepositions (zu, nach).',
      'Panchami (പഞ്ചമി - ൽ നിന്ന് - Ablativ)': 'Ablative suffix -il ninnu (വീട്ടിൽ നിന്ന്). Matches German Dativ with prepositions "aus" and "von".',
      'Shashthi (ഷഷ്ഠി - ഉടെ/ന്റെ - Genitiv)': 'Genitive possessive suffix -uṭe/-ṉṟe (എന്റെ). Matches German Genitiv (des Mannes).',
      'Saptami (സപ്തമി - ൽ - Lokativ)': 'Locative suffix -il (നഗരത്തിൽ). Matches German Dativ with static preposition "in".',
    },
    this.culturalIslamicLexicon = const {
      'നമസ്കാരം / സലാം': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'നന്ദി / ശുക്രിയ': 'Danke / Dankbarkeit (Arabic: شكراً)',
      'ദയവായി': 'Bitte',
      'പുസ്തകം / കിതാബ്': 'Buch (Arabic: كتاب)',
      'പള്ളി': 'Moschee / Gotteshaus',
      'വിദ്യാലയം / മദ്രസ': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'അധ്യാപകൻ / ഉസ്താദ്': 'Lehrer / Meister (Persian: استاد)',
      'വിദ്യ / ഇൽമ്': 'Wissen / Wissenschaft (Arabic: علم)',
      'നീതി / അദാലത്ത്': 'Gerechtigkeit (Arabic: عدالة)',
      'നിസ്കാരം / നമസ്കാരം': 'Gebet / Salāt (Persian: نماز)',
      'ഹലാൽ': 'Erlaubt / Halal (Arabic: حلال)',
      'സുഹൃത്ത് / ചങ്ങാതി': 'Freund',
      'വെള്ളം': 'Wasser',
      'അപ്പം / റൊട്ടി': 'Brot / Nahrung',
      'വീട്': 'Haus / Heim',
      'പട്ടണം / നഗരം': 'Stadt',
      'ആശുപത്രി': 'Krankenhaus',
      'മരുന്നുകട': 'Apotheke',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct match to Malayalam "ശ" (e.g., സ്കൂൾ -> Schule, schön).',
      'z /ts/': 'German affricate /ts/; mapped to compound "ത്+സ്" (Zeit -> Tsait).',
      'ch /x/ (ach-Laut)': 'Mapped via velar fricative release contrasting with aspirated "ഖ".',
      'ö /ø/ & ü /y/': 'Front rounded vowels mapped through systematic lip rounding from Malayalam /e/ and /i/.',
      'Verb Conjugation Drill': 'Since Malayalam verbs do not change for person/number (njan pokunnu = ich gehe, avan pokunnu = er geht), systematic drills train German person endings (-e, -st, -t, -en).',
      'Chillu Coda Bridge': 'Malayalam Chillu letters (ൻ, ൽ, ർ) provide an ideal native phonetic foundation for pronouncing German coda consonants without epenthesis.',
    },
    this.coreA1Vocabulary = const {
      'നമസ്കാരം / സലാം': 'Hallo / Guten Tag',
      'സുപ്രഭാതം': 'Guten Morgen',
      'ശുഭദിനം': 'Guten Tag',
      'ശുഭസായാഹ്നം': 'Guten Abend',
      'വളരെ നന്ദി': 'Vielen Dank',
      'ദയവായി': 'Bitte',
      'അതെ': 'Ja',
      'അല്ല': 'Nein',
      'എന്റെ പേര് ...': 'Mein Name ist ...',
      'നിങ്ങൾ എവിടെ നിന്നാണ്?': 'Woher kommen Sie?',
      'ഞാൻ ... നിന്നാണ് വരുന്നത്': 'Ich komme aus ...',
      'വെള്ളം': 'Wasser',
      'റൊട്ടി': 'Brot',
      'ആശുപത്രി': 'Krankenhaus',
      'മരുന്നുകട': 'Apotheke',
      'റെയിൽവേ സ്റ്റേഷൻ': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'malayalam': 'നമസ്കാരം! നിങ്ങൾക്ക് ജർമ്മൻ സംസാരിക്കാൻ കഴിയുമോ?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'malayalam': 'അതെ, ഞാൻ ഇപ്പോൾ ജർമ്മൻ ഭാഷ പഠിക്കുകയാണ്.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'malayalam': 'ദയവായി പറയൂ, ഏറ്റവും അടുത്തുള്ള മരുന്നുകട എവിടെയാണ്?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'malayalam': 'നിങ്ങളുടെ സഹായത്തിന് വളരെ നന്ദി!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates Malayalam case suffix to German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
