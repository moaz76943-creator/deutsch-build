import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Tigrinya (ትግርኛ / Təgrəñña).
///
/// South Semitic language spoken by 10M+ people in Eritrea and Ethiopia (Tigray),
/// with over 100,000 speakers across Germany and Switzerland. Characterized by
/// Ge'ez Fidel script, Semitic triliteral roots, SOV word order (verb-final mirror),
/// ejective consonants, and deep shared Semitic cognates with Arabic and Amharic.
@immutable
class TigrinyaDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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

  const TigrinyaDeepLocalizationProfile({
    this.languageName = 'Tigrinya',
    this.autonym = 'ትግርኛ',
    this.iso6391 = 'ti',
    this.iso6392or3 = 'tir',
    this.typology = TypologicalClassification.fusionalInflected,
    this.primaryWordOrder = CanonicalWordOrder.sov,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = false,
    this.hasGrammaticalGender = true, // Masculine & Feminine
    this.writingDirection = 'ltr',
    this.primaryScript = 'Ge\'ez script (ፊደል - Fidel)',
    this.ejectiveConsonants = const ['ቀ', 'ጠ', 'ጨ', 'ጸ', 'ቐ'],
    this.semiticCognateBridges = const {
      'ሰላም (selam)': 'Arabic: سلام (Salam / Friede).',
      'ቤት (bēt)': 'Arabic: بيت (Bayt / Haus).',
      'ደም (dem)': 'Arabic: دم (Dam / Blut).',
      'ልቢ (lɪbbi)': 'Arabic: قلب / لب (Qalb / Herz).',
      'ርእሲ (rə\'si)': 'Arabic: رأس (Ra\'s / Kopf).',
      'ዓይኒ (ayni)': 'Arabic: عين (Ayn / Auge).',
      'ኢድ (id)': 'Arabic: يد (Yad / Hand).',
    },
    this.caseSystemAlignment = const {
      'Nominativ (Subject)': 'Unmarked subject in SOV sentence (እቲ ሰብኣይ የንብብ). Maps to German Nominativ (der Mann liest).',
      'Akkusativ (Direct Object - ን... / n...)': 'Accusative prefix n- (ነቲ ሰብኣይ ረኣይክዎ). Directly maps to German Akkusativ (ich sah den Mann).',
      'Dativ (Recipient - ን... / n...)': 'Prefix n- for recipient (ነቲ ሰብኣይ መጽሓፍ ሃብክዎ). Maps to German Dativ (ich gab dem Mann das Buch).',
      'Genitiv (Possession - ናይ... / nay...)': 'Possessive particle nay- (ናይቲ መምህር መጽሓፍ). Directly maps to German Genitiv (das Buch des Lehrers).',
      'Instrumentalis (ብ... / b...)': 'Prefix b- (ብእርሳስ). Maps to German Dativ with preposition "mit".',
      'Lokativ (ኣብ... / ab...)': 'Prefix ab- (ኣብ ከተማ). Maps to German Dativ with static preposition "in".',
      'Ablativ (ካብ... / kab...)': 'Prefix kab- (ካብ ገዛ). Maps to German Dativ with prepositions "aus" and "von".',
    },
    this.culturalIslamicLexicon = const {
      'ሰላም / ከመይ ኣለኻ/ኺ': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'የቐንየለይ / ኣመስግን': 'Danke / Vielen Dank',
      'ብኽብረትካ/ኪ': 'Bitte',
      'መጽሓፍ / ኪታብ': 'Buch (Arabic: كتاب)',
      'ቤት ትምህርቲ / መድረሳ': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'መምህር / ኡስታዝ': 'Lehrer / Meister (Persian: استاد)',
      'ፍልጠት / ሳይንስ': 'Wissen / Wissenschaft',
      'ፍትሒ': 'Gerechtigkeit',
      'ሶላት / ጸሎት': 'Gebet / Salāt (Arabic: صلاة)',
      'ሀላል': 'Erlaubt / Halal (Arabic: حلال)',
      'ዓርኪ / መሓዛ': 'Freund',
      'ማይ': 'Wasser',
      'ባኒ / ቅጫ': 'Brot / Nahrung',
      'ገዛ': 'Haus / Heim',
      'ከተማ': 'Stadt',
      'ሆስፒታል': 'Krankenhaus',
      'ፋርማሲ / ቤት መድሃኒት': 'Apotheke',
      'መስጊድ': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Tigrinya "ሸ" (ሸሚዝ, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Tigrinya "ቸ" (ሻይ/ቸር, Deutschland).',
      'ch /x/ (ach-Laut)': 'Direct 1:1 match to Tigrinya "ኸ" (ኸደ, Bach, Nacht).',
      'z /ts/': 'German affricate /ts/; mapped to Tigrinya ejective affricate "ጸ" or compound "ት+ስ" (Zeit -> Tsait).',
      'SOV Subordinate Mirror': 'Tigrinya natively places verbs at the very end of clauses, making German subordinate clause verb-final word order (weil ich Deutsch lerne) completely natural!',
    },
    this.coreA1Vocabulary = const {
      'ሰላም': 'Hallo / Guten Tag',
      'ደሓንዶ ሓዲርኩም': 'Guten Morgen',
      'ደሓንዶ ውዒልኩም': 'Guten Tag',
      'ደሓንዶ ኣምሲኹም': 'Guten Abend',
      'የቐንየለይ ብጣዕሚ': 'Vielen Dank',
      'ብኽብረትካ': 'Bitte',
      'እወ': 'Ja',
      'ኣይፋልን': 'Nein',
      'ስመይ ... ይበሃል': 'Mein Name ist ...',
      'ካበይ መጺእካ/ኪ?': 'Woher kommen Sie?',
      'ኣነ ካብ ... መጺአ': 'Ich komme aus ...',
      'ማይ': 'Wasser',
      'ባኒ': 'Brot',
      'ሆስፒታል': 'Krankenhaus',
      'ፋርማሲ': 'Apotheke',
      'መደበር ባቡር': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'tigrinya': 'ሰላም! ጀርመንኛ ትዛረብ/ቢ ዶ?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'tigrinya': 'እወ፣ ሕጂ ቋንቋ ጀርመን ይምሃር ኣለኹ።',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'tigrinya': 'ብኽብረትካ፣ እቲ ዝቐረበ ፋርማሲ ኣበይ ኣሎ?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'tigrinya': 'ብዛዕባ ሓገዝካ/ኪ ብጣዕሚ የቐንየለይ!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Tigrinya case prefix into its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
