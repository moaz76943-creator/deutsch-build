import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Nepali (नेपाली).
///
/// Northern Indo-Aryan (Pahari) language spoken by 30M+ people in Nepal and India.
/// Features Devanagari script, SOV word order, two grammatical genders (masc/fem),
/// split ergative marking via postposition 'ले' (-le), a 4-tier honorific pronoun
/// system (tã/timi/tapaaĩ/hajur) bridging directly to German "du" vs "Sie",
/// and a 7-case Vibhakti framework.
@immutable
class NepaliDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final bool hasErgativeMarker; // postposition -le
  final bool hasFormalPronounDistinction; // tapaaĩ/hajur (Sie) vs timi/tã (du)
  final String wordOrder;
  final Map<String, String> honorificPronounBridge;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const NepaliDeepLocalizationProfile({
    this.languageName = 'Nepali',
    this.autonym = 'नेपाली',
    this.iso6391 = 'ne',
    this.iso6392 = 'nep',
    this.languageFamily = 'Indo-European',
    this.branch = 'Indo-Aryan (Northern zone / Pahari)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Devanagari',
    this.hasErgativeMarker = true,
    this.hasFormalPronounDistinction = true,
    this.wordOrder = 'SOV',
    this.honorificPronounBridge = const {
      'तपाईं (Tapaaĩ) / हजुर (Hajur)': 'German formal polite "Sie" (honorific address in professional/social settings).',
      'तिमी (Timi)': 'German informal "du" (among friends, peers, and younger family members).',
      'तँ (Tã)': 'German intimate "du" (extremely close family or literary usage).',
      'ऊ (U) / उहाँ (Uhã)': 'German 3rd person singular "er/sie" (with honorific Uhã matching respectful 3rd person).',
    },
    this.caseSystemAlignment = const {
      'Prathama (प्रथमा - ले / शून्य)': 'Subject form, marked with -le in transitive perfective. Matches German Nominativ (der Mann).',
      'Dvitiya (द्वितीया - लाई / -laai)': 'Definite object marker (किताबलाई). Directly maps to German Akkusativ (das Buch).',
      'Tritiya (तृतीया - ले / द्वारा)': 'Instrumental marker (कलमले). Matches German Dativ with preposition "mit".',
      'Chaturthi (चतुर्थी - लाई / को लागि)': 'Dative/purposive marker (उसलाई / कामका लागि). Matches German Dativ & preposition "für".',
      'Panchami (पञ्चमी - बाट / देखि)': 'Ablative source marker (घरबाट). Matches German Dativ with prepositions "aus" and "von".',
      'Shashthi (षष्ठी - को / का / की)': 'Genitive possessive marker agreeing with possessed noun. Matches German Genitiv (des Mannes).',
      'Saptami (सप्तमी - मा)': 'Locative marker (शहरमा). Matches German Dativ with static preposition "in".',
    },
    this.culturalIslamicLexicon = const {
      'नमस्ते / सलाम': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'धन्यवाद / शुक्रिया': 'Danke / Dankbarkeit (Arabic: شكراً)',
      'कृपया / मेहेरबानी गरी': 'Bitte / Freundlichkeit (Persian: مهرباني)',
      'किताब / पुस्तक': 'Buch (Arabic: كتاب)',
      'विद्यालय / मदरसा': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'शिक्षक / उस्ताद': 'Lehrer / Meister (Persian: استاد)',
      'ज्ञान / इल्म': 'Wissen / Wissenschaft (Arabic: علم)',
      'न्याय / अदालत': 'Gerechtigkeit (Arabic: عدالة)',
      'नमाज / प्रार्थना': 'Gebet / Salāt (Persian: نماز)',
      'हलाल / शुद्ध': 'Erlaubt / Halal (Arabic: حلال)',
      'साथी / मित्र / दोस्त': 'Freund (Persian: دوست)',
      'पानी': 'Wasser',
      'रोटी': 'Brot / Nahrung',
      'घर': 'Haus / Heim',
      'शहर': 'Stadt (Persian: شهر)',
      'अस्पताल': 'Krankenhaus',
      'औषधि पसल': 'Apotheke',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct match to Nepali "श" (e.g., शहर -> Schule, schön).',
      'z /ts/': 'German affricate /ts/; practiced as compound "त्+स" (Zeit -> Tsait).',
      'ch /x/ (ach-Laut)': 'Mapped via velar release contrasting with Nepali aspirated "ख".',
      'ö /ø/ & ü /y/': 'Front rounded vowels mapped through systematic lip rounding from Nepali /e/ and /i/.',
      'Honorific Register Alignment': 'Nepali learners leverage their rich 4-tier honorific system to effortlessly adopt the German polite "Sie" vs informal "du" distinction.',
    },
    this.coreA1Vocabulary = const {
      'नमस्ते / सलाम': 'Hallo / Guten Tag',
      'शुभ प्रभात': 'Guten Morgen',
      'शुभ दिन': 'Guten Tag',
      'शुभ साँझ': 'Guten Abend',
      'धेरै धेरै धन्यवाद': 'Vielen Dank',
      'कृपया': 'Bitte',
      'हजुर / हो': 'Ja',
      'होइन': 'Nein',
      'मेरो नाम ... हो': 'Mein Name ist ...',
      'तपाईं कहाँबाट आउनुभएको हो?': 'Woher kommen Sie?',
      'म ... बाट आएको हुँ': 'Ich komme aus ...',
      'पानी': 'Wasser',
      'रोटी': 'Brot',
      'अस्पताल': 'Krankenhaus',
      'औषधि पसल': 'Apotheke',
      'रेलवे स्टेशन': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'nepali': 'नमस्ते! के तपाईं जर्मन बोल्नुहुन्छ?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'nepali': 'हजुर, म अहिले जर्मन भाषा सिक्दैछु।',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'nepali': 'कृपया भन्नुहोस्, नजिकैको औषधि पसल कहाँ छ?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'nepali': 'तपाईंको सहयोगको लागि धेरै धेरै धन्यवाद!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Nepali case suffix to its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
