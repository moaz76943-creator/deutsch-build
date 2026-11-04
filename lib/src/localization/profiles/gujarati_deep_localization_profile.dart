import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Gujarati (ગુજરાતી).
///
/// Major Indo-Aryan language spoken by 60M+ people.
/// Uniquely preserves the archaic 3-gender Indo-European system:
/// Masculine (પુલ્લિંગ), Feminine (સ્ત્રીલિંગ), and Neuter (નપુંસકલિંગ),
/// providing an exact 1:1 cognitive bridge to German "der, die, das"!
@immutable
class GujaratiDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final bool hasThreeGenders; // Exact match to German der, die, das!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const GujaratiDeepLocalizationProfile({
    this.languageName = 'Gujarati',
    this.autonym = 'ગુજરાતી',
    this.iso6391 = 'gu',
    this.iso6392 = 'guj',
    this.languageFamily = 'Indo-European',
    this.branch = 'Indo-Aryan (Western zone)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Gujarati script (without shirorekha)',
    this.hasThreeGenders = true,
    this.wordOrder = 'SOV',
    this.genderEquivalenceMap = const {
      'Puling (પુલ્લિંગ)': 'German Maskulinum (der) - e.g., છોકરો (der Junge), સુરજ (die Sonne/masc).',
      'Striling (સ્ત્રીલિંગ)': 'German Femininum (die) - e.g., છોકરી (das Mädchen/fem), રાત (die Nacht).',
      'Napunsakling (નપુંસકલિંગ)': 'German Neutrum (das) - e.g., છોકરું (das Kind), પુસ્તક (das Buch).',
    },
    this.caseSystemAlignment = const {
      'Direct Case (પ્રથમા / કર્તા)': 'Unmarked subject form (છોકરો વાંચે છે). Direct match to German Nominativ (der Junge liest).',
      'Accusative/Dative Postposition (-ને / -ne)': 'Direct/indirect object marker (છોકરાને / chokra-ne). Matches German Akkusativ & Dativ.',
      'Genitive Postposition (-નો/-ની/-નું/-ના / -no/-ni/-nu/-na)': 'Agrees with possessed noun in gender and case. Matches German Genitiv (des Buches).',
      'Instrumental/Ablative Postposition (-થી / -thi)': 'Means or origin (ઘરથી / ghar-thi). Matches German Dativ with "mit" and "aus/von".',
      'Locative Postposition (-માં / -ma)': 'Indicates location inside (શહેરમાં / shahar-ma). Matches German Dativ with preposition "in".',
    },
    this.culturalIslamicLexicon = const {
      'સલામ': 'Friede / Begrüßung (Arabic: سلام)',
      'આભાર / શુક્રિયા': 'Danke / Dankbarkeit (Arabic: شكراً)',
      'કૃપા કરીને / મહેરબાની કરીને': 'Bitte / Freundlichkeit (Arabic/Persian: مهرباني)',
      'પુસ્તક / કિતાબ': 'Buch (Arabic: كتاب)',
      'શાળા / મક્તબ': 'Schule (Arabic: مكتب)',
      'શિક્ષક / ઉસ્તાદ': 'Lehrer / Meister (Persian: استاد)',
      'વિદ્યા / ઇલ્મ': 'Wissen / Wissenschaft (Arabic: علم)',
      'ન્યાય / અદાલત': 'Gerechtigkeit (Arabic: عدالة)',
      'નમાઝ': 'Gebet / Salāt (Persian: نماز)',
      'હલાલ': 'Erlaubt / Halal (Arabic: حلال)',
      'મિત્ર / દોસ્ત': 'Freund (Persian: دوست)',
      'પાણી': 'Wasser',
      'રોટલી': 'Brot / Nahrung',
      'ઘર': 'Haus / Heim',
      'શહેર': 'Stadt (Persian: شهر)',
      'હોસ્પિટલ / દવાખાનું': 'Krankenhaus (Persian: دواخانه)',
      'દવાઓની દુકાન': 'Apotheke',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Gujarati "શ" (e.g., શહેર, શાળા, Schule, schön).',
      'z /ts/': 'German affricate /ts/; mapped to Gujarati conjunct "ત્સ" (e.g., ઉત્સવ, Zeit -> Tsait).',
      'ch /x/ (ach-Laut)': 'Corresponds to uvular fricative; mapped to aspirated "ખ" with slight velar friction.',
      'ö /ø/ & ü /y/': 'Front rounded vowels mapped through systematic lip-rounding drills from Gujarati /e/ and /i/.',
      '3-Gender Advantage': 'Gujarati learners intuitively possess a 3-gender mental framework, removing the greatest hurdle in German article acquisition (der, die, das).',
    },
    this.coreA1Vocabulary = const {
      'નમસ્તે / સલામ': 'Hallo / Guten Tag',
      'સુપ્રભાત': 'Guten Morgen',
      'શુભ બપોર': 'Guten Tag',
      'શુભ સંધ્યા': 'Guten Abend',
      'ખૂબ ખૂબ આભાર': 'Vielen Dank',
      'કૃપા કરીને': 'Bitte',
      'હા': 'Ja',
      'ના': 'Nein',
      'મારું નામ ... છે': 'Mein Name ist ...',
      'તમે ક્યાંથી છો?': 'Woher kommen Sie?',
      'હું ... થી છું': 'Ich komme aus ...',
      'પાણી': 'Wasser',
      'રોટલી': 'Brot',
      'હોસ્પિટલ': 'Krankenhaus',
      'દવાની દુકાન': 'Apotheke',
      'રેલ્વે સ્ટેશન': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'gujarati': 'નમસ્તે! શું તમે જર્મન બોલો છો?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'gujarati': 'હા, હું હાલમાં જર્મન ભાષા શીખી રહ્યો છું.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'gujarati': 'કૃપા કરીને, સૌથી નજીકની દવાની દુકાન ક્યાં છે?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'gujarati': 'તમારી મદદ માટે ખૂબ ખૂબ આભાર!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Demonstrates the unique 3-gender structural correspondence to German.
  bool matchesGermanThreeGenders() {
    return hasThreeGenders && genderEquivalenceMap.length == 3;
  }
}
