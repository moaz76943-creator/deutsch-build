import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Hindi (हिन्दी / हिंदी).
///
/// Major Indo-Aryan lingua franca spoken by 600M+ people.
/// Features Devanagari script, two grammatical genders (पुल्लिंग/स्त्रीलिंग),
/// SOV word order, deep Indo-European historical cognates (नावा/नाम/माता/पिता),
/// three-tier honorific pronouns (तू, तुम, आप matching German du vs Sie),
/// and a postpositional case system with ergative 'ने' (ne).
@immutable
class HindiDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final bool hasGrammaticalGender;
  final String wordOrder;
  final Map<String, String> indoEuropeanCognateBridges;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const HindiDeepLocalizationProfile({
    this.languageName = 'Hindi',
    this.autonym = 'हिन्दी',
    this.iso6391 = 'hi',
    this.iso6392 = 'hin',
    this.languageFamily = 'Indo-European',
    this.branch = 'Indo-Aryan (Central zone)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Devanagari',
    this.hasGrammaticalGender = true, // Masculine & Feminine
    this.wordOrder = 'SOV',
    this.indoEuropeanCognateBridges = const {
      'नाम (Naam)': 'German "Name" (Cognate from PIE *h₁nómn̥).',
      'माता / माँ (Mata / Maa)': 'German "Mutter" (Cognate from PIE *méh₂tēr).',
      'पिता (Pita)': 'German "Vater" (Cognate from PIE *ph₂tḗr).',
      'भ्राता / भाई (Bhrata / Bhai)': 'German "Bruder" (Cognate from PIE *bʰréh₂tēr).',
      'दो (Do)': 'German "zwei" (Cognate from PIE *dwóh₁).',
      'तीन (Teen)': 'German "drei" (Cognate from PIE *tréyes).',
      'नौ (Nau)': 'German "neun" (Cognate from PIE *h₁néwn̥).',
    },
    this.caseSystemAlignment = const {
      'Direct Case (प्रत्यक्ष रूप)': 'Unmarked subject form (लड़का किताब पढ़ता है). Direct match to German Nominativ (der Junge liest das Buch).',
      'Ergative Postposition -ने (-ne)': 'Subject marker in transitive perfective aspect. Maps to German past tense subject (er hat gelesen).',
      'Accusative/Dative Postposition -को (-ko)': 'Marks definite direct object and indirect object. Directly corresponds to German Akkusativ & Dativ.',
      'Instrumental/Ablative Postposition -से (-se)': 'Means, separation or origin. Corresponds to German Dativ with prepositions "mit", "von", "aus".',
      'Genitive Postposition -का/-की/-के (-ka/-ki/-ke)': 'Agrees with possessed noun in gender and case. Corresponds to German Genitiv (des Mannes).',
      'Locative Postposition -में/-पर (-mein/-par)': 'Location inside or upon. Corresponds to German Dativ with prepositions "in" and "auf".',
    },
    this.culturalIslamicLexicon = const {
      'नमस्ते / सलाम': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'धन्यवाद / शुक्रिया': 'Danke / Dankbarkeit (Arabic: شكراً)',
      'कृपया / मेहरबानी करके': 'Bitte / Freundlichkeit (Persian: مهرباني)',
      'किताब / पुस्तक': 'Buch (Arabic: كتاب)',
      'स्कूल / मदरसा': 'Schule (Arabic: مدرسة)',
      'उस्ताद / शिक्षक': 'Lehrer / Meister (Persian: استاد)',
      'इल्म / ज्ञान': 'Wissen / Wissenschaft (Arabic: علم)',
      'अदालत / न्याय': 'Gerechtigkeit (Arabic: عدالة)',
      'नमाज़ / प्रार्थना': 'Gebet / Salāt (Persian: نماز)',
      'हलाल / शुद्ध': 'Erlaubt / Halal (Arabic: حلال)',
      'दोस्त / मित्र': 'Freund (Persian: دوست)',
      'पानी': 'Wasser',
      'रोटी': 'Brot / Nahrung',
      'घर': 'Haus / Heim',
      'शहर': 'Stadt (Persian: شهر)',
      'अस्पताल': 'Krankenhaus',
      'दवाखाना / दवाई की दुकान': 'Apotheke',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Hindi "श" (e.g., शहर, स्कूल -> Schule, schön).',
      'ch /x/ (ach-Laut)': 'Direct match to Urdu/Hindi loan letter "ख़" (e.g., ख़बर, ख़ास -> Nacht, Buch).',
      'z /ts/': 'German affricate /ts/; mapped to compound "त्+स" (Zeit -> Tsait).',
      'ö /ø/ & ü /y/': 'Front rounded vowels mapped through systematic lip rounding from Hindi /e/ and /i/.',
      'Honorific Triad Bridge': 'Hindi 3-way pronoun system (तू = intimate, तुम = informal, आप = formal) directly anchors the German distinction between "du" and "Sie".',
    },
    this.coreA1Vocabulary = const {
      'नमस्ते / सलाम': 'Hallo / Guten Tag',
      'शुभ प्रभात': 'Guten Morgen',
      'शुभ दोपहर': 'Guten Tag',
      'शुभ संध्या': 'Guten Abend',
      'बहुत-बहुत धन्यवाद': 'Vielen Dank',
      'कृपया': 'Bitte',
      'हाँ': 'Ja',
      'नहीं': 'Nein',
      'मेरा नाम ... है': 'Mein Name ist ...',
      'आप कहाँ से हैं?': 'Woher kommen Sie?',
      'मैं ... से हूँ': 'Ich komme aus ...',
      'पानी': 'Wasser',
      'रोटी': 'Brot',
      'अस्पताल': 'Krankenhaus',
      'दवाई की दुकान': 'Apotheke',
      'रेलवे स्टेशन': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'hindi': 'नमस्ते! क्या आप जर्मन बोलते हैं?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'hindi': 'हाँ, मैं अभी जर्मन भाषा सीख रहा हूँ।',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'hindi': 'कृपया बताइए, सबसे नज़दीकी दवाई की दुकान कहाँ है?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'hindi': 'आपकी मदद के लिए बहुत-बहुत धन्यवाद!',
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
