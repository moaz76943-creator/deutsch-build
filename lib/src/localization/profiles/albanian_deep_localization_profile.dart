import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Albanian (Gjuha shqipe / Shqip).
///
/// Distinct Indo-European branch spoken by 7.5M+ people in Albania, Kosovo,
/// North Macedonia, and large diaspora in Germany and Switzerland. Characterized by
/// 3 grammatical genders, postposed definite article morphology (libër -> libri),
/// a 5-case system, and native letter 'Y/y' (/y/) providing a 100% native acoustic
/// match to German 'ü' (über, fünf)!
@immutable
class AlbanianDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasThreeGenders; // Mashkullore, Femërore, Asnjanëse
  final bool hasPostposedDefiniteArticles; // libri, burri, gruaja
  final bool hasNativeGermanUSound; // Albanian 'y' = German 'ü' (/y/)!
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const AlbanianDeepLocalizationProfile({
    this.languageName = 'Albanian',
    this.autonym = 'Gjuha shqipe',
    this.iso6391 = 'sq',
    this.iso6392 = 'sqi',
    this.languageFamily = 'Indo-European',
    this.branch = 'Albanian (Independent branch)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Manastir alphabet)',
    this.specialCharacters = const ['ç', 'ë', 'dh', 'gj', 'll', 'nj', 'rr', 'sh', 'th', 'xh', 'zh'],
    this.hasThreeGenders = true,
    this.hasPostposedDefiniteArticles = true,
    this.hasNativeGermanUSound = true, // 'y' is strictly /y/
    this.wordOrder = 'SVO',
    this.caseSystemAlignment = const {
      'Rasa Emërore (Nominativ)': 'Subject form (burri / libri). Directly maps to German Nominativ (der Mann / das Buch).',
      'Rasa Gjinore (Genitiv)': 'Marked by pre-inflection articles i/e/të/së (i librit). Directly maps to German Genitiv (des Buches).',
      'Rasa Dhanore (Dativ)': 'Indirect object (burrit / gruas). Directly maps to German Dativ (dem Mann / der Frau).',
      'Rasa Kallëzore (Akkusativ)': 'Direct object (burrin / librin). Directly maps to German Akkusativ (den Mann / das Buch).',
      'Rasa Rrjedhore (Ablativ)': 'Origin and separation with prepositions "nga", "prej". Maps to German Dativ with "aus" and "von".',
    },
    this.culturalIslamicLexicon = const {
      'selam / përshëndetje': 'Friede / Begrüßung (Arabic: سلام)',
      'faleminderit': 'Danke / Dankbarkeit',
      'ju lutem / të lutem': 'Bitte',
      'libër / qitap': 'Buch (Arabic: كتاب)',
      'shkollë / medrese': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'mësues / hoxhë': 'Lehrer / Gelehrter (Persian: خواجه)',
      'dituri / ilm': 'Wissen / Wissenschaft (Arabic: علم)',
      'drejtësi / adalet': 'Gerechtigkeit (Arabic: عدالة)',
      'namaz / falje': 'Gebet / Salāt (Persian: نماز)',
      'hallall': 'Erlaubt / Halal (Arabic: حلال)',
      'mik / shok / dost': 'Freund (Persian: دوست)',
      'ujë': 'Wasser',
      'bukë': 'Brot / Nahrung',
      'shtëpi': 'Haus / Heim',
      'qytet / sheher': 'Stadt (Persian: شهر)',
      'spital': 'Krankenhaus',
      'farmaci / barnatore': 'Apotheke',
      'xhami': 'Moschee (Arabic: جامع)',
      'besa': 'Treue / Ehrenwort',
    },
    this.germanPhoneticBridges = const {
      'ü /y/': '100% Native Identity! Albanian "Y / y" is naturally pronounced as /y/ (close front rounded vowel, e.g. yll, dy), matching German "ü" (über, fünf, Tür) flawlessly!',
      'z /ts/': '100% Native Identity! Albanian "C / c" is strictly /ts/ (e.g. cigare, cipë), matching German "z" (Zeit, Zug, Zimmer) with zero distortion!',
      'sch /ʃ/': 'Direct 1:1 match to Albanian "Sh / sh" (shkollë, shtëpi, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Albanian "Ç / ç" (çadër, çelës, Deutschland).',
      'Article Inversion Bridge': 'Albanian uses postposed definite suffixes (-i, -u, -a, -t), requiring contrastive cognitive exercises to invert to German preposed articles (der, die, das).',
    },
    this.coreA1Vocabulary = const {
      'Përshëndetje / Selam': 'Hallo / Guten Tag',
      'Mirëmëngjes': 'Guten Morgen',
      'Mirëdita': 'Guten Tag',
      'Mirëmbrëma': 'Guten Abend',
      'Shumë faleminderit': 'Vielen Dank',
      'Ju lutem': 'Bitte',
      'Po': 'Ja',
      'Jo': 'Nein',
      'Emri im është ...': 'Mein Name ist ...',
      'Nga jeni ju?': 'Woher kommen Sie?',
      'Unë jam nga ...': 'Ich komme aus ...',
      'Ujë': 'Wasser',
      'Bukë': 'Brot',
      'Spital': 'Krankenhaus',
      'Farmaci': 'Apotheke',
      'Stacioni i trenit': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'albanian': 'Përshëndetje! A flisni gjermanisht?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'albanian': 'Po, unë po mësoj gjuhën gjermane tani.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'albanian': 'Ju lutem, ku ndodhet farmacia më e afërt?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'albanian': 'Shumë faleminderit për ndihmën tuaj!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates an Albanian case to its German counterpart.
  String? getGermanCaseBridge(String rasaName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(rasaName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
