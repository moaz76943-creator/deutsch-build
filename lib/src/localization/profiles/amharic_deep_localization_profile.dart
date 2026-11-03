import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Amharic (አማርኛ / Amarəñña).
///
/// South Semitic language spoken by 35M+ people in Ethiopia. Characterized by Ge'ez
/// Fidel abugida syllabary (231 glyphs), triliteral root-and-pattern morphology, SOV
/// clause structure (verb-final mirror matching German subordinate clauses and Turkish),
/// ejective consonants (ጠ, ጨ, ጰ, ጸ, ቀ), and profound shared Semitic cognates with Arabic.
@immutable
class AmharicDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final List<String> ejectiveConsonants;
  final Map<String, String> semiticCognateBridges;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const AmharicDeepLocalizationProfile({
    this.languageName = 'Amharic',
    this.autonym = 'አማርኛ',
    this.iso6391 = 'am',
    this.iso6392or3 = 'amh',
    this.typology = TypologicalClassification.fusionalInflected,
    this.primaryWordOrder = CanonicalWordOrder.sov,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = false,
    this.hasGrammaticalGender = true, // Masculine & Feminine
    this.writingDirection = 'ltr',
    this.primaryScript = 'Ge\'ez script (ፊደል - Fidel)',
    this.ejectiveConsonants = const ['ቀ', 'ጠ', 'ጨ', 'ጰ', 'ጸ', 'ፀ'],
    this.semiticCognateBridges = const {
      'ሰላም (selam)': 'Arabic: سلام (Salam / Friede) - PIE: peace.',
      'ደም (dem)': 'Arabic: دم (Dam / Blut).',
      'ቤት (bēt)': 'Arabic: بيت (Bayt / Haus).',
      'ዐይን (ayn)': 'Arabic: عين (Ayn / Auge).',
      'ራስ (ras)': 'Arabic: رأس (Ra\'s / Kopf / Chef).',
      'ልብ (lɪbb)': 'Arabic: قلب / لب (Qalb / Herz).',
      'እጅ (əǧ)': 'Arabic: يد (Yad / Hand).',
    },
    this.caseSystemAlignment = const {
      'Nominativ (Subject)': 'Unmarked subject in SOV sentence (ሰውየው ያነባል). Maps to German Nominativ (der Mann liest).',
      'Akkusativ (Direct Object - -ን / -n)': 'Definite object suffix -n (መጽሐፉን አነበበ). Directly maps to German Akkusativ (er las das Buch).',
      'Dativ (Recipient - ለ... / le...)': 'Prefix le- (ለሰውየው ሰጠሁ). Maps to German Dativ (ich gab dem Mann).',
      'Genitiv (Possessive - የ... / ye...)': 'Prefix ye- (የአስተማሪው መጽሐፍ). Maps to German Genitiv (das Buch des Lehrers).',
      'Instrumentalis (በ... / be...)': 'Prefix be- (በእርሳስ). Maps to German Dativ with preposition "mit".',
      'Circumpositions (በ...ውስጥ, ከ...ጋር)': 'Frames indicating spatial relations. Maps to German prepositions "in", "mit", "aus".',
    },
    this.culturalIslamicLexicon = const {
      'ሰላም / እንዴት ነዎት': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'አመሰግናለሁ / በጣም አመሰግናለሁ': 'Danke / Vielen Dank',
      'እባክዎን': 'Bitte',
      'መጽሐፍ / ኪታብ': 'Buch (Arabic: كتاب)',
      'ትምህርት ቤት / መድረሳ': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'አስተማሪ / ኡስታዝ': 'Lehrer / Meister (Persian: استاد)',
      'እውቀት / ሳይንስ': 'Wissen / Wissenschaft',
      'ፍትህ': 'Gerechtigkeit',
      'ሶላት / ጸሎት': 'Gebet / Salāt (Arabic: صلاة)',
      'ሀላል': 'Erlaubt / Halal (Arabic: حلال)',
      'ጓደኛ / ወዳጅ': 'Freund',
      'ውሃ': 'Wasser',
      'ዳቦ': 'Brot / Nahrung',
      'ቤት': 'Haus / Heim',
      'ከተማ': 'Stadt',
      'ሆስፒታል': 'Krankenhaus',
      'ፋርማሲ / የመድኃኒት ቤት': 'Apotheke',
      'መስጊድ': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Amharic "ሸ" (e.g. ሸሚዝ, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Amharic "ቸ" (e.g. ሻይ/ቸር, Deutschland).',
      'z /ts/': 'German affricate /ts/; mapped to Amharic ejective dental affricate "ጸ" or compound "ት+ስ" (Zeit -> Tsait).',
      'ch /x/ (ach-Laut)': 'Direct match to Amharic "ኸ" (e.g. ኸሚስ, Bach, Nacht).',
      'SOV Subordinate Mirror': 'Amharic natively places verbs at the very end of clauses, making German subordinate clause verb-final word order (weil ich Deutsch lerne) completely natural!',
    },
    this.coreA1Vocabulary = const {
      'ሰላም': 'Hallo / Guten Tag',
      'እንደምን አደሩ': 'Guten Morgen',
      'እንደምን ዋሉ': 'Guten Tag',
      'እንደምን አመሹ': 'Guten Abend',
      'በጣም አመሰግናለሁ': 'Vielen Dank',
      'እባክዎን': 'Bitte',
      'አዎ': 'Ja',
      'አይደለም': 'Nein',
      'ስሜ ... ይባላል': 'Mein Name ist ...',
      'ከየት ነዎት?': 'Woher kommen Sie?',
      'እኔ ከ ... ነኝ': 'Ich komme aus ...',
      'ውሃ': 'Wasser',
      'ዳቦ': 'Brot',
      'ሆስፒታል': 'Krankenhaus',
      'ፋርማሲ': 'Apotheke',
      'ባቡር ጣቢያ': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'amharic': 'ሰላም! ጀርመንኛ መናገር ይችላሉ?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'amharic': 'አዎ፣ አሁን የጀርመን ቋንቋ እየተማርኩ ነው።',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'amharic': 'እባክዎን በአቅራቢያ የሚገኘው ፋርማሲ የት ነው?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'amharic': 'ስለ እርዳታዎ በጣም አመሰግናለሁ!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates an Amharic case structure into its German equivalent.
  String? getGermanCaseBridge(String relationName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(relationName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
