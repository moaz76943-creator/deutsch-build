import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Turkmen (Türkmen dili).
///
/// Turkic language family (East Oghuz branch) spoken by 7M+ people in Turkmenistan,
/// Iran, Afghanistan, and Uzbekistan. Distinguishes primary vowel length,
/// strict front/back and rounding vowel harmony, native umlauts (ö, ü) offering
/// a 100% natural acoustic bridge to German, 6 grammatical cases, and SOV clause syntax.
@immutable
class TurkmenDeepLocalizationProfile {
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
  final bool hasPrimaryVowelLength;
  final bool hasVowelHarmony;
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const TurkmenDeepLocalizationProfile({
    this.languageName = 'Turkmen',
    this.autonym = 'Türkmen dili',
    this.iso6391 = 'tk',
    this.iso6392 = 'tuk',
    this.languageFamily = 'Turkic',
    this.branch = 'Oghuz (East Oghuz)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (official)',
    this.specialCharacters = const ['ä', 'ž', 'ň', 'ö', 'ş', 'ü', 'ý'],
    this.isAgglutinative = true,
    this.hasPrimaryVowelLength = true, // Unique archaic trait preserved in Turkmen
    this.hasVowelHarmony = true,
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'Baş düşüm (Nominativ)': 'Unmarked base form (kitap). Directly maps to German Nominativ (das Buch).',
      'Eýelik düşüm (Genitiv)': 'Suffix -yň / -iň (kitabyň). Directly maps to German Genitiv (des Buches).',
      'Ýöneliş düşüm (Dativ / Allativ)': 'Suffix -a / -e (mekdebe). Maps to German Dativ and directional prepositions (zu, nach).',
      'Ýeňiş düşüm (Akkusativ)': 'Suffix -y / -i (kitaby). Directly maps to German definite Akkusativ (das Buch / den Mann).',
      'Wagt-orun düşüm (Lokativ)': 'Suffix -da / -de (mekdepde). Maps to German Dativ with static prepositions (in, an, bei).',
      'Çykyş düşüm (Ablativ)': 'Suffix -dan / -den (mekdepden). Maps to German Dativ with source prepositions (aus, von).',
    },
    this.culturalIslamicLexicon = const {
      'salam / essalamu aleýkum': 'Friede / Begrüßung (Arabic: سلام)',
      'sag boluň / taňryýalkasyn': 'Danke / Gott segne dich',
      'haýyş / başüstüne': 'Bitte / Gern geschehen',
      'kitap': 'Buch (Arabic: كتاب)',
      'mekdep': 'Schule (Arabic: مكتب)',
      'mugallym': 'Lehrer (Arabic: معلم)',
      'ylym': 'Wissenschaft / Wissen (Arabic: علم)',
      'adalat': 'Gerechtigkeit (Arabic: عدالة)',
      'namaz': 'Gebet / Salāt (Persian/Arabic: نماز / صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'dost': 'Freund (Persian: دوست)',
      'suw': 'Wasser',
      'çörek': 'Brot / Nahrung',
      'öý': 'Haus / Heim',
      'şäher': 'Stadt (Persian: شهر)',
      'hassahana': 'Krankenhaus (Persian: خسته خانه)',
      'dermanhana': 'Apotheke (Persian: درمان خانه)',
    },
    this.germanPhoneticBridges = const {
      'ö /ø/ & ü /y/': '100% Native Identity! Turkmen "ö" (göz, köp) and "ü" (gül, üç) match German "ö" (schön) and "ü" (über) with zero acoustic distortion.',
      'ä /æ/ & ä /ɛ/': 'Turkmen "ä" (käte, kär) provides an immediate intuitive bridge to German "ä" (Männer, Äpfel).',
      'sch /ʃ/': 'Direct 1:1 match to Turkmen "ş" (şäher, Schule, schön).',
      'ch /x/ (ach-Laut)': 'Mapped via Turkmen velar/uvular fricative in Arabic loanwords (habar, Bach, Nacht).',
      'Vowel Length Transfer': 'Turkmen primary vowel length (short vs long vowels) maps naturally to the German distinction between short (Bett, Schiff) and long (Beet, schief) vowels.',
    },
    this.coreA1Vocabulary = const {
      'Salam / Essalamu aleýkum': 'Hallo / Guten Tag',
      'Ertiriňiz haýyrly bolsun': 'Guten Morgen',
      'Günüňiz haýyrly bolsun': 'Guten Tag',
      'Agşamyňyz haýyrly bolsun': 'Guten Abend',
      'Köp sag boluň': 'Vielen Dank',
      'Haýyş edýärin': 'Bitte',
      'Hawa': 'Ja',
      'Ýok': 'Nein',
      'Meniň adym ...': 'Mein Name ist ...',
      'Siz nireden?': 'Woher kommen Sie?',
      'Men ...-dan/den': 'Ich komme aus ...',
      'Suw': 'Wasser',
      'Çörek': 'Brot',
      'Hassahana': 'Krankenhaus',
      'Dermanhana': 'Apotheke',
      'Wokzal / Demirýol menzili': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'turkmen': 'Salam! Siz nemesçe gürläp bilýärsiňizmi?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'turkmen': 'Hawa, men häzir nemes dilini öwrenýärin.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'turkmen': 'Haýyş edýärin, iň ýakyn dermanhana nirede?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'turkmen': 'Kömegiňiz üçin köp sag boluň!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Confirms that Turkmen possesses native German umlauts ö and ü.
  bool hasNativeGermanUmlauts() {
    return specialCharacters.contains('ö') && specialCharacters.contains('ü');
  }

  /// Translates a Turkmen case suffix to its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
