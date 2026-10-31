import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Telugu (తెలుగు).
///
/// South-Central Dravidian language spoken by 95M+ people ("Italian of the East").
/// Noted for vowel-ending word structures, strict SOV word order, agglutinative
/// 7-case Vibhakti framework, and vowel harmony across nominal and verbal suffixes.
@immutable
class TeluguDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final bool isAgglutinative;
  final bool hasVowelHarmonicSuffixes;
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const TeluguDeepLocalizationProfile({
    this.languageName = 'Telugu',
    this.autonym = 'తెలుగు',
    this.iso6391 = 'te',
    this.iso6392 = 'tel',
    this.languageFamily = 'Dravidian',
    this.branch = 'South-Central Dravidian',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Telugu script',
    this.isAgglutinative = true,
    this.hasVowelHarmonicSuffixes = true,
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'Prathama Vibhakti (ప్రథమా విభక్తి - డు, ము, వు, లు)': 'Base subject form. Matches German Nominativ (der Mann).',
      'Dvitiya Vibhakti (ద్వితీయా విభక్తి - ను, ని)': 'Accusative object marker. Matches German Akkusativ (den Mann / das Buch).',
      'Tritiya Vibhakti (తృతీయా విభక్తి - తో, చేత)': 'Instrumental & Sociative marker. Matches German Dativ with "mit".',
      'Chaturthi Vibhakti (చతుర్థీ విభక్తి - కొరకు, కై)': 'Dative/purposive marker. Matches German Dativ & preposition "für".',
      'Panchami Vibhakti (పంచమీ విభక్తి - వలన, నుండి)': 'Ablative source marker. Matches German Dativ with prepositions "aus" and "von".',
      'Shashthi Vibhakti (షష్ఠీ విభక్తి - యొక్క, కు, కి)': 'Genitive/possessive marker. Matches German Genitiv (des Buches).',
      'Saptami Vibhakti (సప్తమీ విభక్తి - అందు, లో)': 'Locative marker. Matches German Dativ with static preposition "in".',
    },
    this.culturalIslamicLexicon = const {
      'నమస్కారం / సలాం': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'ధన్యవాదాలు / శుక్రియా': 'Danke / Dankbarkeit (Arabic: شكراً)',
      'దయచేసి / మెహర్బానీ చేసి': 'Bitte (Persian: مهرباني)',
      'పుస్తకం / కితాబ్': 'Buch (Arabic: كتاب)',
      'పాఠశాల / మక్తబ్': 'Schule (Arabic: مكتب)',
      'ఉపాధ్యాయుడు / ఉస్తాద్': 'Lehrer / Meister (Persian: استاد)',
      'విద్య / ఇల్మ్': 'Wissen / Wissenschaft (Arabic: علم)',
      'న్యాయం / అదాలత్': 'Gerechtigkeit (Arabic: عدالة)',
      'నమాజ్ / ప్రార్థన': 'Gebet / Salāt (Persian: نماز)',
      'హలాల్': 'Erlaubt / Halal (Arabic: حلال)',
      'స్నేహితుడు / దోస్త్': 'Freund (Persian: دوست)',
      'నీరు': 'Wasser',
      'రొట్టె': 'Brot / Nahrung',
      'ఇల్లు': 'Haus / Heim',
      'నగరం / షహర్': 'Stadt (Persian: شهر)',
      'ఆసుపత్రి': 'Krankenhaus',
      'మందుల దుకాణం': 'Apotheke',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct match to Telugu "శ" (e.g., పాఠశాల -> Schule, schön).',
      'z /ts/': 'German affricate /ts/; practiced as compound "త్+స్" (Zeit -> Tsait).',
      'ch /x/ (ach-Laut)': 'Mapped via velar release contrasting with Telugu aspirated "ఖ".',
      'ö /ø/ & ü /y/': 'Front rounded vowels mapped through systematic lip rounding from Telugu /e/ and /i/.',
      'Vowel Coda Contrast': 'Telugu natively prefers open syllables (ending in vowels); training focuses on crisp German consonant codas (Geld, Freund, Stadt).',
    },
    this.coreA1Vocabulary = const {
      'నమస్కారం / సలాం': 'Hallo / Guten Tag',
      'శుభోదయం': 'Guten Morgen',
      'శుభ మధ్యాహ్నం': 'Guten Tag',
      'శుభ సాయంత్రం': 'Guten Abend',
      'చాలా ధన్యవాదాలు': 'Vielen Dank',
      'దయచేసి': 'Bitte',
      'అవును': 'Ja',
      'కాదు': 'Nein',
      'నా పేరు ...': 'Mein Name ist ...',
      'మీరు ఎక్కడి నుండి వచ్చారు?': 'Woher kommen Sie?',
      'నేను ... నుండి వచ్చాను': 'Ich komme aus ...',
      'నీరు': 'Wasser',
      'రొట్టె': 'Brot',
      'ఆసుపత్రి': 'Krankenhaus',
      'మందుల దుకాణం': 'Apotheke',
      'రైల్వే స్టేషన్': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'telugu': 'నమస్కారం! మీరు జర్మన్ మాట్లాడగలరా?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'telugu': 'అవును, నేను ప్రస్తుతం జర్మన్ భాష నేర్చుకుంటున్నాను.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'telugu': 'దయచేసి చెప్పండి, దగ్గరలోని మందుల దుకాణం ఎక్కడ ఉంది?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'telugu': 'మీ సహాయానికి చాలా ధన్యవాదాలు!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates Telugu Vibhakti case to German equivalent.
  String? getGermanCaseBridge(String vibhaktiName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(vibhaktiName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
