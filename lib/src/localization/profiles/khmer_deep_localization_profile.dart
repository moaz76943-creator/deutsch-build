import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Khmer (ភាសាខ្មែរ / Phéasa Khmêr).
///
/// Austroasiatic (Mon-Khmer) language spoken by 16M+ people. Characterized by
/// the historic Khmer script (74 letters with subscript consonant feet / coeng),
/// vocalic register phonology (clear first series vs breathy second series),
/// isolating SVO syntax, deep Sanskrit/Pali loanword inventory, and Cham Muslim lexicon.
@immutable
class KhmerDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final int totalScriptGlyphs;
  final Map<String, String> registerPhonologyBridge;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const KhmerDeepLocalizationProfile({
    this.languageName = 'Khmer',
    this.autonym = 'ភាសាខ្មែរ',
    this.iso6391 = 'km',
    this.iso6392or3 = 'khm',
    this.typology = TypologicalClassification.isolatingAnalytic,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.analyticalPrepositional,
    this.hasTones = false, // Register voice-quality language rather than tonal!
    this.hasGrammaticalGender = false,
    this.writingDirection = 'ltr',
    this.primaryScript = 'Khmer script (អក្សរខ្មែរ)',
    this.totalScriptGlyphs = 74,
    this.registerPhonologyBridge = const {
      'First Series (Clear Register)': 'Consonants pronounced with open clear head voice (ក, ច, ដ, ត, ប, etc.). Directly maps to standard German unvoiced/clear vowels.',
      'Second Series (Breathy Register)': 'Consonants pronounced with deeper breathy chest voice (គ, ជ, ឌ, ទ, ព, etc.). Prepares learners for voiced/lax vocalic environments.',
    },
    this.caseSystemAlignment = const {
      'Nominativ (Subject)': 'Unmarked subject position in SVO (បុរសនោះអាន). Maps to German Nominativ (der Mann liest).',
      'Akkusativ (Direct Object)': 'Direct object following verb (អានសៀវភៅ). Maps to German Akkusativ (das Buch lesen).',
      'Dativ (Recipient - ដល់ / ឲ្យ)': 'Preposition "dal" or "aoy" (ឲ្យបុរសនោះ). Directly maps to German Dativ (dem Mann geben).',
      'Genitiv (Possessive - របស់)': 'Preposition "roboh" (សៀវភៅរបស់គ្រូ). Directly maps to German Genitiv (das Buch des Lehrers).',
      'Instrumentalis (ដោយ)': 'Preposition "daoy" (ដោយឡាន). Maps to German Dativ with preposition "mit".',
      'Lokativ (ក្នុង / នៅ)': 'Prepositions "knong", "nov" (ក្នុងទីក្រុង). Maps to German Dativ with prepositions "in" and "an".',
    },
    this.culturalIslamicLexicon = const {
      'ជំរាបសួរ / សួស្តី / សាឡាម': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'អរគុណ / អរគុណច្រើន': 'Danke / Vielen Dank',
      'សូម / សូមមេត្តា': 'Bitte',
      'សៀវភៅ / គម្ពីរ': 'Buch (Arabic: كتاب)',
      'សាលារៀន / ម៉ាដ្រាសា': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'គ្រូបង្រៀន / សាស្រ្តាចារ្យ': 'Lehrer / Professor',
      'ចំណេះដឹង / វិទ្យាសាស្ត្រ': 'Wissen / Wissenschaft',
      'យុត្តិធម៌': 'Gerechtigkeit',
      'ការបន់ស្រន់ / សាឡាត': 'Gebet / Salāt (Arabic: صلاة)',
      'ហាឡាល់': 'Erlaubt / Halal (Arabic: حلال)',
      'មិត្តភក្តិ': 'Freund',
      'ទឹក': 'Wasser',
      'នំបុ័ង': 'Brot / Nahrung (French loan: pain)',
      'ផ្ទះ': 'Haus / Heim',
      'ទីក្រុង': 'Stadt',
      'មន្ទីរពេទ្យ': 'Krankenhaus',
      'ឱសថស្ថាន': 'Apotheke',
      'វិហារអ៊ីស្លាម / ម៉ัสជิด': 'Moschee (Arabic: جامع / مسجد)',
    },
    this.coreA1Vocabulary = const {
      'ជំរាបសួរ / សួស្តី': 'Hallo / Guten Tag',
      'អរុណសួស្តី': 'Guten Morgen',
      'ទិវាសួស្តី': 'Guten Tag',
      'សាយ័ណ្ហសួស្តី': 'Guten Abend',
      'អរគុណច្រើន': 'Vielen Dank',
      'សូម': 'Bitte',
      'បាទ / ចាស': 'Ja (Male: Baat / Female: Chaas)',
      'ទេ': 'Nein',
      'ខ្ញុំឈ្មោះ ...': 'Mein Name ist ...',
      'តើអ្នកមកពីណា?': 'Woher kommen Sie?',
      'ខ្ញុំមកពី ...': 'Ich komme aus ...',
      'ទឹក': 'Wasser',
      'នំបុ័ង': 'Brot',
      'មន្ទីរពេទ្យ': 'Krankenhaus',
      'ឱសថស្ថាន': 'Apotheke',
      'ស្ថានីយ៍រថភ្លើង': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'khmer': 'ជំរាបសួរ! តើអ្នកចេះនិយាយភាសាអាល្លឺម៉ង់ទេ?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'khmer': 'បាទ/ចាស, ខ្ញុំកំពុងរៀនភាសាអាល្លឺម៉ង់ឥឡូវនេះ។',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'khmer': 'សូមអភ័យទោស, តើឱសថស្ថានដែលនៅជិតបំផុតនៅឯណា?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'khmer': 'អរគុណច្រើនសម្រាប់ជំនួយរបស់អ្នក!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Khmer prepositional relation into its German equivalent.
  String? getGermanCaseBridge(String relationName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(relationName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
