import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Odia (ଓଡ଼ିଆ).
///
/// Classical Eastern Indo-Aryan language spoken by 38M+ people in Odisha.
/// Characterized by distinctive circular top palm-leaf script, SOV word order,
/// vowel harmony, postpositional Vibhakti cases, and absence of grammatical articles
/// requiring structured German Der/Die/Das pedagogical drills.
@immutable
class OdiaDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasGrammaticalArticles; // false in Odia
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const OdiaDeepLocalizationProfile({
    this.languageName = 'Odia',
    this.autonym = 'ଓଡ଼ିଆ',
    this.iso6391 = 'or',
    this.iso6392 = 'ori',
    this.languageFamily = 'Indo-European',
    this.branch = 'Indo-Aryan (Eastern zone / Magadhan)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Odia script (rounded palm-leaf script)',
    this.specialCharacters = const ['ଳ', 'ଡ଼', 'ଢ଼', 'ୟ', 'ୱ', 'ଂ', 'ଃ'],
    this.hasGrammaticalArticles = false,
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'Prathama (ପ୍ରଥମା - Nominativ)': 'Unmarked base subject form (ପିଲାଟି). Direct match to German Nominativ (das Kind).',
      'Dvitiya (ଦ୍ୱିତୀୟା - କୁ / -ku - Akkusativ)': 'Definite object marker (ବହିକୁ). Directly maps to German Akkusativ (das Buch).',
      'Tritiya (ତୃତୀୟା - ଦ୍ୱାରା/ରେ / -dwara/-re)': 'Instrumental marker. Matches German Dativ with preposition "mit".',
      'Chaturthi (ଚତୁର୍ଥୀ - ପାଇଁ/କୁ / -pain/-ku)': 'Dative/purposive marker. Matches German Dativ & preposition "für".',
      'Panchami (ପଞ୍ଚମୀ - ରୁ/ଠାରୁ / -ru/-tharu)': 'Ablative source marker (ଘରୁ). Matches German Dativ with prepositions "aus" and "von".',
      'Shashthi (ଷଷ୍ଠୀ - ର / -ra - Genitiv)': 'Genitive possessive marker (ପିଲାର). Matches German Genitiv (des Kindes).',
      'Saptami (ସପ୍ତମୀ - ରେ/ଠାରେ / -re/-thare)': 'Locative marker (ସହରରେ). Matches German Dativ with static preposition "in".',
    },
    this.culturalIslamicLexicon = const {
      'ନମସ୍କାର / ସଲାମ': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'ଧନ୍ୟବାଦ / ଶୁକ୍ରିୟା': 'Danke / Dankbarkeit (Arabic: شكراً)',
      'ଦୟାକରି / ମେହେରବାନୀ କରି': 'Bitte / Freundlichkeit (Persian: مهرباني)',
      'ବହି / କିତାବ': 'Buch (Arabic: كتاب)',
      'ବିଦ୍ୟାଳୟ / ମଦ୍ରାସା': 'Schule (Arabic: مدرسة)',
      'ଶିକ୍ଷକ / ଓସ୍ତାଦ': 'Lehrer / Meister (Persian: استاد)',
      'ଜ୍ଞାନ / ଇଲ୍ମ': 'Wissen / Wissenschaft (Arabic: علم)',
      'ନ୍ୟାୟ / ଅଦାଲତ': 'Gerechtigkeit (Arabic: عدالة)',
      'ନମାଜ': 'Gebet / Salāt (Persian: نماز)',
      'ହଲାଲ': 'Erlaubt / Halal (Arabic: حلال)',
      'ସାଙ୍ଗ / ବନ୍ଧୁ / ଦୋସ୍ତ': 'Freund (Persian: دوست)',
      'ପାଣି': 'Wasser',
      'ରୁଟି': 'Brot / Nahrung',
      'ଘର': 'Haus / Heim',
      'ସହର': 'Stadt (Persian: شهر)',
      'ଡାକ୍ତରଖାନା': 'Krankenhaus',
      'ଔଷଧ ଦୋକାନ': 'Apotheke',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct match to Odia "ଶ" (e.g., ଶହର -> Schule, schön).',
      'z /ts/': 'German affricate /ts/; practiced as compound "ତ୍+ସ" (Zeit -> Tsait).',
      'ch /x/ (ach-Laut)': 'Mapped via velar release contrasting with aspirated "ଖ".',
      'ö /ø/ & ü /y/': 'Front rounded vowels mapped through systematic lip rounding from Odia /e/ and /i/.',
      'Article System Drill': 'Because Odia uses numeral classifiers (e.g. -ta, -ti) rather than grammatical articles, learners receive targeted training for der, die, das.',
    },
    this.coreA1Vocabulary = const {
      'ନମସ୍କାର / ସଲାମ': 'Hallo / Guten Tag',
      'ଶୁଭ ସକାଳ': 'Guten Morgen',
      'ଶୁଭ ମଧ୍ୟାହ୍ନ': 'Guten Tag',
      'ଶୁଭ ସନ୍ଧ୍ୟା': 'Guten Abend',
      'ଅନେକ ଅନେକ ଧନ୍ୟବାଦ': 'Vielen Dank',
      'ଦୟାକରି': 'Bitte',
      'ହଁ': 'Ja',
      'ନାହିଁ': 'Nein',
      'ମୋର ନାମ ...': 'Mein Name ist ...',
      'ଆପଣ କେଉଁଠାରୁ ଆସିଛନ୍ତି?': 'Woher kommen Sie?',
      'ମୁଁ ... ରୁ ଆସିଛି': 'Ich komme aus ...',
      'ପାଣି': 'Wasser',
      'ରୁଟି': 'Brot',
      'ଡାକ୍ତରଖାନା': 'Krankenhaus',
      'ଔଷଧ ଦୋକାନ': 'Apotheke',
      'ରେଳ ଷ୍ଟେସନ': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'odia': 'ନମସ୍କାର! ଆପଣ ଜର୍ମାନ କହିପାରିବେ କି?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'odia': 'ହଁ, ମୁଁ ବର୍ତ୍ତମାନ ଜର୍ମାନ ଭାଷା ଶିଖୁଛି।',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'odia': 'ଦୟାକରି କୁହନ୍ତୁ, ସବୁଠାରୁ ପାଖ ଔଷଧ ଦୋକାନ କେଉଁଠାରେ ଅଛି?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'odia': 'ଆପଣଙ୍କ ସାହାଯ୍ୟ ପାଇଁ ଅନେକ ଅନେକ ଧନ୍ୟବାଦ!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates an Odia case suffix to its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
