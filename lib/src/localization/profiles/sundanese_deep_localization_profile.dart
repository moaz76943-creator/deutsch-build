import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Sundanese (Basa Sunda / ᮘᮞ ᮞᮥᮔ᮪ᮓ).
///
/// Austronesian language spoken by 40M+ people in West Java and Banten (Indonesia).
/// Characterized by speech levels (Loma = informal 'du', Lemes = polite formal 'Sie'),
/// productive plural infixes (-ar- / -al-), agglutinative morphology, Latin and
/// Aksara Sunda scripts, and deep Priangan Islamic cultural heritage.
@immutable
class SundaneseDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final Map<String, String> speechLevelHonorificBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const SundaneseDeepLocalizationProfile({
    this.languageName = 'Sundanese',
    this.autonym = 'Basa Sunda',
    this.iso6391 = 'su',
    this.iso6392or3 = 'sun',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = false,
    this.hasGrammaticalGender = false,
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (official modern) / Aksara Sunda (ᮘᮞ ᮞᮥᮔ᮪ᮓ)',
    this.speechLevelHonorificBridge = const {
      'Basa Loma (Informal Familiar)': 'Used with close friends, family, and peers. Maps directly to German informal "du".',
      'Basa Lemes (Polite Formal)': 'Used in respectful public, professional, and cross-generational address. Maps directly to German formal "Sie".',
      'Plural Infixation (-ar- / -al-)': 'Productive plural marker inside root (budak -> barudak). Prepares learners for internal root changes like German Umlaut plurals (Mann -> Männer).',
    },
    this.culturalIslamicLexicon = const {
      'wilujeng / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'hatur nuhun / hatur nuhun pisan': 'Danke / Vielen Dank',
      'punten / mangga': 'Bitte / Entschuldigung',
      'buku / kitab': 'Buch (Arabic: كتاب)',
      'sakola / pesantrén / madrasah': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'guru / ustadh': 'Lehrer / Dozent (Arabic: أستاذ)',
      'pangaweruh / élmu': 'Wissen / Wissenschaft (Arabic: علم)',
      'keadilan / adil': 'Gerechtigkeit (Arabic: عدالة)',
      'ibadah / salat': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'réréncangan / sobat': 'Freund',
      'cai': 'Wasser',
      'roti': 'Brot / Nahrung',
      'bumi / rorompok': 'Haus / Heim',
      'kota': 'Stadt',
      'rumah sakit': 'Krankenhaus',
      'apoték': 'Apotheke',
      'masjid': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Sundanese "Sy / sy" (syukur, syarat, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Sundanese "C / c" (/tʃ/) (cai, cicing, Deutschland).',
      'z /ts/': 'German "z" is an affricate /ts/, practiced as the compound sequence "t+s" (tsunami -> Zeit).',
      'ch /x/ (ach-Laut)': 'Direct match to Sundanese "Kh / kh" in Islamic loanwords (khabar, ikhlas, Bach, Nacht).',
    },
    this.coreA1Vocabulary = const {
      'Wilujeng / Sampurasun': 'Hallo / Guten Tag',
      'Wilujeng enjing': 'Guten Morgen',
      'Wilujeng siang': 'Guten Tag',
      'Wilujeng wengi': 'Guten Abend',
      'Hatur nuhun pisan': 'Vielen Dank',
      'Punten': 'Bitte',
      'Muhun / Enya': 'Ja (Lemes: Muhun / Loma: Enya)',
      'Henteu / Moal': 'Nein',
      'Wasta pun / Nami abdi ...': 'Mein Name ist ...',
      'Kawit ti mana?': 'Woher kommen Sie?',
      'Abdi ti ...': 'Ich komme aus ...',
      'Cai': 'Wasser',
      'Roti': 'Brot',
      'Rumah sakit': 'Krankenhaus',
      'Apoték': 'Apotheke',
      'Stasion karéta': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'sundanese': 'Wilujeng siang! Dupi anjeun tiasa basa Jérman?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'sundanese': 'Muhun, abdi nuju diajar basa Jérman ayeuna.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'sundanese': 'Punten, apoték anu pangcaketna di mana nya?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'sundanese': 'Hatur nuhun pisan kana bantosan anjeun!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
