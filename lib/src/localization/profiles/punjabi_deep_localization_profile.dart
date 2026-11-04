import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Punjabi (ਪੰਜਾਬੀ / پنجابی).
///
/// Major Indo-Aryan language spoken by 125M+ people across Pakistan and India.
/// Features dual-script support (Shahmukhi Perso-Arabic & Gurmukhi Brahmic),
/// unique lexical tonal system (Low, Mid, High), two grammatical genders,
/// postpositional case infrastructure, and SOV clause architecture.
@immutable
class PunjabiDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final List<String> supportedScripts;
  final bool hasTones;
  final bool hasGrammaticalGender;
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const PunjabiDeepLocalizationProfile({
    this.languageName = 'Punjabi',
    this.autonym = 'ਪੰਜਾਬੀ / پنجابی',
    this.iso6391 = 'pa',
    this.iso6392 = 'pan',
    this.languageFamily = 'Indo-European',
    this.branch = 'Indo-Aryan (Northwestern zone)',
    this.supportedScripts = const ['Shahmukhi (Perso-Arabic - rtl)', 'Gurmukhi (Brahmic - ltr)'],
    this.hasTones = true, // Unique lexical tone among Indo-Aryan
    this.hasGrammaticalGender = true, // Masculine & Feminine
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'Direct Case (ਸਿੱਧਾ ਰੂਪ / سدھا روپ)': 'Unmarked subject form (ਮੁੰਡਾ / منڈا). Maps to German Nominativ (der Junge).',
      'Oblique Case (ਮੋੜਵਾਂ ਰੂਪ / موڑواں روپ)': 'Governed by postpositions (ਮੁੰਡੇ ਨੂੰ / منڈے نوں). Bridges to German Akkusativ & Dativ.',
      'Dative/Accusative Postposition (ਨੂੰ / نوں)': 'Marks recipient or specific patient. Directly corresponds to German Dativ (dem Mann) & Akkusativ (den Mann).',
      'Genitive Postposition (ਦਾ/ਦੀ/ਦੇ / دا/دی/دے)': 'Indicates possession with gender concordance (ਕਿਤਾਬ ਦਾ ਪੰਨਾ). Direct match to German Genitiv (des Buches).',
      'Ablative Postposition (ਤੋਂ / توں)': 'Indicates source or origin (ਘਰ ਤੋਂ). Mapped to German Dativ with source prepositions (aus dem Haus / von).',
      'Locative Postposition (ਵਿੱਚ / وچ)': 'Indicates location inside (ਸ਼ਹਿਰ ਵਿੱਚ). Mapped to German Dativ with static preposition "in" (in der Stadt).',
    },
    this.culturalIslamicLexicon = const {
      'ਸਲਾਮ / سلام': 'Friede / Begrüßung (Arabic: سلام)',
      'ਸ਼ੁਕਰੀਆ / شکریہ': 'Danke / Dankbarkeit (Arabic: شكرية)',
      'ਮਿਹਰਬਾਨੀ / مہربانی': 'Bitte / Freundlichkeit (Arabic/Persian: مهرباني)',
      'ਕਿਤਾਬ / کتاب': 'Buch (Arabic: كتاب)',
      'ਸਕੂਲ / ਸਕੂਲ': 'Schule',
      'ਉਸਤਾਦ / استاد': 'Lehrer / Meister (Persian: استاد)',
      'ਇਲਮ / علم': 'Wissen / Wissenschaft (Arabic: علم)',
      'ਇਨਸਾਫ਼ / انصاف': 'Gerechtigkeit (Arabic: إنصاف)',
      'ਨਮਾਜ਼ / نماز': 'Gebet / Salāt (Persian: نماز)',
      'ਹਲਾਲ / حلال': 'Erlaubt / Halal (Arabic: حلال)',
      'ਦੋਸਤ / دوست': 'Freund (Persian: دوست)',
      'ਪਾਣੀ / پانی': 'Wasser',
      'ਰੋਟੀ / روٹی': 'Brot / Nahrung',
      'ਘਰ / گھر': 'Haus / Heim',
      'ਸ਼ਹਿਰ / شہر': 'Stadt (Persian: شهر)',
      'ਹਸਪਤਾਲ / ہسپتال': 'Krankenhaus',
      'ਦਵਾਈਆਂ ਦੀ ਦੁਕਾਨ / دوائیاں دی دکان': 'Apotheke',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Punjabi "ਸ਼ / ش" (e.g., ਸ਼ਹਿਰ, Schule, schön).',
      'ch /x/ (ach-Laut)': 'Direct match to Punjabi "ਖ਼ / خ" (e.g., ਖ਼ਬਰ, Bach, Nacht).',
      'z /ts/': 'German "z" is an affricate /ts/; mapped to Punjabi compound "ਤ+ਸ / ت+س" (Zeit -> Tsait).',
      'ch /ç/ (ich-Laut)': 'Palatal fricative practiced without velar friction, distinct from "ਖ਼".',
      'ö /ø/ & ü /y/': 'Front rounded vowels absent in Punjabi; acquired through systematic lip rounding from /e/ and /i/.',
      'Tonal Pitch Control': 'Punjabi learners leverage innate pitch modulation to master German sentence intonation contours.',
    },
    this.coreA1Vocabulary = const {
      'ਸਤਿ ਸ੍ਰੀ ਅਕਾਲ / سلام': 'Hallo / Guten Tag',
      'ਸ਼ੁਭ ਸਵੇਰ / صبح بخیر': 'Guten Morgen',
      'ਸ਼ੁਭ ਦੁਪਹਿਰ / دوپہر بخیر': 'Guten Tag',
      'ਸ਼ੁਭ ਸ਼ਾਮ / شام بخیر': 'Guten Abend',
      'ਬਹੁਤ ਸ਼ੁਕਰੀਆ / بہت شکریہ': 'Vielen Dank',
      'ਕਿਰਪਾ ਕਰਕੇ / مہربانی کر کے': 'Bitte',
      'ਹਾਂ / ہاں': 'Ja',
      'ਨਹੀਂ / نہیں': 'Nein',
      'ਮੇਰਾ ਨਾਮ ... ਹੈ / میرا ناں ... اے': 'Mein Name ist ...',
      'ਤੁਸੀਂ ਕਿੱਥੋਂ ਹੋ? / تسیں کتھوں او؟': 'Woher kommen Sie?',
      'ਮੈਂ ... ਤੋਂ ਹਾਂ / میں ... توں آں': 'Ich komme aus ...',
      'ਪਾਣੀ / پانی': 'Wasser',
      'ਰੋਟੀ / روٹی': 'Brot',
      'ਹਸਪਤਾਲ / ہسپتال': 'Krankenhaus',
      'ਦਵਾਈਆਂ ਦੀ ਦੁਕਾਨ / دوائیاں دی دکان': 'Apotheke',
      'ਰੇਲਵੇ ਸਟੇਸ਼ਨ / ریلوے اسٹیشن': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'punjabi': 'ਸਲਾਮ! ਕੀ ਤੁਸੀਂ ਜਰਮਨ ਬੋਲਦੇ ਹੋ? / سلام! کی تسیں جرمن بولدے او؟',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'punjabi': 'ਹਾਂ, ਮੈਂ ਜਰਮਨ ਭਾਸ਼ਾ ਸਿੱਖ ਰਿਹਾ ਹਾਂ। / ہاں، میں جرمن زبان سکھ رہیا آں۔',
        'german': 'Ja, ich lerne die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية.',
      },
      {
        'punjabi': 'ਮਿਹਰਬਾਨੀ ਕਰਕੇ, ਸਭ ਤੋਂ ਨੇੜਲੀ ਦਵਾਖਾਨਾ ਕਿੱਥੇ ਹੈ? / مہربانی کر کے، سب توں نیڑے دوائی دی دکان کتھے اے؟',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'punjabi': 'ਤੁਹਾਡੀ ਮਦਦ ਲਈ ਬਹੁਤ ਸ਼ੁਕਰੀਆ! / تہاڈی مدد لئی بہت شکریہ!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a postpositional grammatical relation into the German case system.
  String? getGermanCaseBridge(String postpositionRelation) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(postpositionRelation.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
