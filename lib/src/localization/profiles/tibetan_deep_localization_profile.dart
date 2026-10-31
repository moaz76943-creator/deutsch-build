import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Tibetan (བོད་སྐད་ / Bodskad).
///
/// Tibetic (Sino-Tibetan) language spoken by 8M+ people. Characterized by
/// the classical 30-consonant Tibetan script (7th century), split ergative-absolutive
/// postpositional case particles, Zhe-sa (ཞེ་ས) honorific speech hierarchy directly
/// anchoring German 'Sie' vs 'du', and strict SOV verb-final sentence architecture.
@immutable
class TibetanDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
  @override
  final String languageName;
  @override
  final String autonym;
  @override
  final String iso6391;
  @override
  final String iso6392or3;
  @override
  final TypologicalClassification typology;
  @override
  final CanonicalWordOrder primaryWordOrder;
  @override
  final GrammaticalAlignment alignment;
  @override
  final bool hasTones;
  @override
  final bool hasGrammaticalGender;

  final String writingDirection;
  final String primaryScript;
  final Map<String, String> zhesaHonorificBridge;
  final Map<String, String> postpositionalCaseAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const TibetanDeepLocalizationProfile({
    this.languageName = 'Tibetan',
    this.autonym = 'བོད་སྐད་',
    this.iso6391 = 'bo',
    this.iso6392or3 = 'bod',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.sov, // Strict verb-final!
    this.alignment = GrammaticalAlignment.ergativeAbsolutive,
    this.hasTones = true, // Tonal in Lhasa standard
    this.hasGrammaticalGender = false,
    this.writingDirection = 'ltr',
    this.primaryScript = 'Tibetan script (དབུ་ཅན་ - Uchen)',
    this.zhesaHonorificBridge = const {
      'Zhe-sa (ཞེ་ས - Polite Honorific)': 'Respectful honorific register used in formal, religious, and esteemed address. Directly anchors German formal "Sie" and polite Konjunktiv II.',
      'Phal-skad (ཕལ་སྐད - Common Speech)': 'Daily informal register among peers and family. Maps directly to German informal "du".',
    },
    this.postpositionalCaseAlignment = const {
      '1. Absolutive / Direct (unmarked)': 'Patient of transitive verb or subject of intransitive. Maps to German Nominativ/Akkusativ.',
      '2. Ergative / Instrumental (-kyis / -gis / -gyis / -s)': 'Agent of transitive verb (ཁོས་དེབ་ཀློག་གི་འདུག). Maps to German transitive subject.',
      '3. Genitive (-kyi / -gi / -gyi / -\'i)': 'Possessive connector (དགེ་རྒན་གྱི་དེབ). Directly maps to German Genitiv (des Lehrers Buch).',
      '4. Dative / Locative (-la)': 'Recipient, destination, or static location (ཁོ་ལ་དེབ་སྤྲད). Directly maps to German Dativ and prepositions "zu", "in".',
      '5. Ablative (-nas / -las)': 'Source or separation (ཁང་པ་ནས). Maps to German Dativ with prepositions "aus" and "von".',
    },
    this.culturalIslamicLexicon = const {
      'བཀྲ་ཤིས་བདེ་ལེགས / སަލཱམ': 'Hallo / Segen / Friede (Arabic: سلام)',
      'ཐུགས་རྗེ་ཆེ / ཐུགས་རྗེ་གནང': 'Danke / Vielen Dank',
      'སྐུ་མཁྱེན': 'Bitte',
      'དཔེ་ཆ / ཀི་ཏབ': 'Buch (Arabic: كتاب)',
      'སློབ་གྲྭ / མདྲས': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'དགེ་རྒན / ཨུསྟད': 'Lehrer / Dozent (Arabic: أستاذ)',
      'ཤེས་ཡོན / ཚན་རིག': 'Wissen / Wissenschaft',
      'དྲང་བདེན': 'Gerechtigkeit',
      'ཁ་འདོན / སལཱཏ': 'Gebet / Salāt (Arabic: صلاة)',
      'ཧ་ལཱལ': 'Erlaubt / Halal (Arabic: حلال)',
      'གྲོགས་པོ': 'Freund',
      'ཆུ': 'Wasser',
      'བག་ལེབ': 'Brot / Nahrung',
      'ཁང་པ': 'Haus / Heim',
      'གྲོང་ཁྱེར': 'Stadt',
      'སྨན་ཁང': 'Krankenhaus',
      'སྨན་ཚོང': 'Apotheke',
      'ཁ་ཆེའི་ལྷ་ཁང / མསྗིད': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Tibetan "ཙ" (/ts/) and aspirated "ཚ" (/tsʰ/) match German "z" (Zeit, Ziel, Zimmer) with zero acoustic distortion!',
      'sch /ʃ/': 'Direct 1:1 match to Tibetan "ཤ" (/ʃ/) (shing, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Tibetan "ཅ" (/tʃ/) and "ཆ" (/tʃʰ/) (Deutschland!).',
      'SOV Subordinate Mirror': 'Tibetan natively places verbs at the end of sentences, making German subordinate clause structure (weil ich Deutsch lerne) completely natural!',
    },
    this.coreA1Vocabulary = const {
      'བཀྲ་ཤིས་བདེ་ལེགས': 'Hallo / Guten Tag',
      'སྔ་དྲོ་བདེ་ལེགས': 'Guten Morgen',
      'ཉིན་མོ་བདེ་ལེགས': 'Guten Tag',
      'དགོང་མོ་བདེ་ལེགས': 'Guten Abend',
      'ཐུགས་རྗེ་ཆེ་ཞུ': 'Vielen Dank',
      'སྐུ་མཁྱེན': 'Bitte',
      'ལགས་ཡིན': 'Ja',
      'ལགས་མིན': 'Nein',
      'ངའི་མིང་ལ་ ... ཟེར': 'Mein Name ist ...',
      'ཁྱེད་རང་ག་ནས་ཡིན་པས?': 'Woher kommen Sie?',
      'ང་ ... ནས་ཡིན': 'Ich komme aus ...',
      'ཆུ': 'Wasser',
      'བག་ལེབ': 'Brot',
      'སྨན་ཁང': 'Krankenhaus',
      'སྨན་ཚོང': 'Apotheke',
      'མེ་འཁོར་བབས་ཚུགས': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'tibetan': 'བཀྲ་ཤིས་བདེ་ལེགས! ཁྱེད་རང་འཇར་མན་སྐད་ཡག་པོ་མཁྱེན་གྱི་ཡོད་པས?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'tibetan': 'ལགས་ཡིན, ང་ད་ལྟ་འཇར་མན་སྐད་སློབ་སྦྱོང་བྱེད་ཀྱི་ཡོད།',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'tibetan': 'སྐུ་མཁྱེན, ཉེ་ཤོས་ཀྱི་སྨན་ཚོང་ག་པར་ཡོད་རེད?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'tibetan': 'ཁྱེད་རང་གིས་རོགས་པ་གནང་བར་ཐུགས་རྗེ་ཆེ་ཞུ!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Tibetan postpositional case into its German equivalent.
  String? getGermanCaseBridge(String particleName) {
    for (final entry in postpositionalCaseAlignment.entries) {
      if (entry.key.toLowerCase().contains(particleName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
