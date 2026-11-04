import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Javanese (Basa Jawa / ꦧꦱꦗꦮ).
///
/// Austronesian language spoken by 85M+ people in Java (Indonesia), Suriname,
/// and Malaysia. Characterized by its famous speech levels / politeness hierarchy
/// (Ngoko = informal 'du', Krama = formal 'Sie', Krama Inggil = honorific subjunctive),
/// agglutinative affixation, Latin and Hanacaraka script, and deep Islamic Mataram heritage.
@immutable
class JavaneseDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final List<Map<String, String>> practicalDialoguePhrases;

  const JavaneseDeepLocalizationProfile({
    this.languageName = 'Javanese',
    this.autonym = 'Basa Jawa',
    this.iso6391 = 'jv',
    this.iso6392or3 = 'jav',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = false,
    this.hasGrammaticalGender = false,
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (official modern) / Hanacaraka (Carakan: ꦧꦱꦗꦮ)',
    this.speechLevelHonorificBridge = const {
      'Ngoko (Informal Everyday)': 'Used with close peers, family, and younger people. Maps directly to German informal "du".',
      'Krama (Formal Respectful)': 'Used in polite public, professional, and cross-generational interactions. Maps directly to German formal "Sie".',
      'Krama Inggil (Highest Honorific)': 'Expresses reverence towards elders and distinguished authorities. Bridges to German courteous subjunctive (könnten Sie bitte...).',
    },
    this.culturalIslamicLexicon = const {
      'sugeng / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'matur nuwun / matur suwun sanget': 'Danke / Vielen Dank',
      'nyuwun tulung / mangga': 'Bitte / Bitte sehr',
      'buku / kitab': 'Buch (Arabic: كتاب)',
      'sekolah / pesantren / madrasah': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'guru / ustadh': 'Lehrer / Dozent (Arabic: أستاذ)',
      'kawruh / ilmu': 'Wissen / Wissenschaft (Arabic: علم)',
      'keadilan / adil': 'Gerechtigkeit (Arabic: عدالة)',
      'salat / sembahyang': 'Gebet / Salāt (Arabic: صلاة)',
      'halal': 'Erlaubt / Halal (Arabic: حلال)',
      'kanca / mitra': 'Freund',
      'banyu / toya': 'Wasser',
      'roti': 'Brot / Nahrung',
      'omah / dalem': 'Haus / Heim',
      'kutha': 'Stadt',
      'rumah sakit': 'Krankenhaus',
      'apotek': 'Apotheke (Dutch loan: apotheek)',
      'masjid': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Javanese "Sy / sy" (syukur, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Javanese "C / c" (/tʃ/) (cilik, Deutschland).',
      'z /ts/': 'German "z" is an affricate /ts/, practiced as compound "t+s" (tsunami -> Zeit).',
      'ch /x/ (ach-Laut)': 'Direct match to Javanese "Kh / kh" in Islamic loanwords (khabar, ikhlas, Bach, Nacht).',
      'Honorific Register Alignment': 'Javanese learners intuitively navigate German polite "Sie" vs informal "du" through their native Ngoko vs Krama speech system.',
    },
    this.coreA1Vocabulary = const {
      'Sugeng / Halo': 'Hallo / Guten Tag',
      'Sugeng enjang': 'Guten Morgen',
      'Sugeng siang': 'Guten Tag',
      'Sugeng dalu': 'Guten Abend',
      'Matur nuwun sanget': 'Vielen Dank',
      'Nyuwun tulung': 'Bitte',
      'Nggih / Iya': 'Ja (Krama: Nggih / Ngoko: Iya)',
      'Mboten / Ora': 'Nein (Krama: Mboten / Ngoko: Ora)',
      'Jenengku / Asma kula ...': 'Mein Name ist ...',
      'Panjenengan saking pundi?': 'Woher kommen Sie?',
      'Kula saking ...': 'Ich komme aus ...',
      'Banyu': 'Wasser',
      'Roti': 'Brot',
      'Rumah sakit': 'Krankenhaus',
      'Apotek': 'Apotheke',
      'Stasiun sepur': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'javanese': 'Sugeng siang! Punapa panjenengan saged basa Jerman?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'javanese': 'Nggih, kula nembe sinau basa Jerman sapunika.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'javanese': 'Nyuwun tulung, apotek ingkang paling caket wonten pundi?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'javanese': 'Matur nuwun sanget kagem pitulungan panjenengan!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
