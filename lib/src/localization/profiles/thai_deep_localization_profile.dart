import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Thai (ภาษาไทย / Phasa Thai).
///
/// Kra-Dai language (Southwestern Tai branch) spoken by 70M+ people. Characterized
/// by continuous Thai abugida writing, 5 phonemic tones, isolating morphology, SVO
/// syntax, rich Sanskrit/Pali loans, Southern Thai Muslim cultural integration, and
/// omnidirectional cross-linguistic alignment across both Asian and European families.
@immutable
class ThaiDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final List<String> toneRegisters;
  final Map<String, String> omnidirectionalBridges;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const ThaiDeepLocalizationProfile({
    this.languageName = 'Thai',
    this.autonym = 'ภาษาไทย',
    this.iso6391 = 'th',
    this.iso6392or3 = 'tha',
    this.typology = TypologicalClassification.isolatingAnalytic,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.analyticalPrepositional,
    this.hasTones = true,
    this.hasGrammaticalGender = false,
    this.writingDirection = 'ltr',
    this.primaryScript = 'Thai script (อักษรไทย)',
    this.toneRegisters = const ['สามัญ (Mid)', 'เอก (Low)', 'โท (Falling)', 'ตรี (High)', 'จัตวา (Rising)'],
    this.omnidirectionalBridges = const {
      'Austronesian/Malay Southern Bridge': 'Intense historical and lexical convergence with Malay in Southern Thailand (Pattani/Satun/Yala).',
      'Indic Sanskrit/Pali Heritage': 'Deep cognate roots with Indo-Aryan languages (Hindi, Bengali, Sinhala) in academic, legal, and spiritual terms.',
      'European Fusional Case Transfer': 'Prepositional frames (ของ = Genitiv, แก่/ให้ = Dativ, ด้วย = mit, ใน = in) directly map to German/Romance/Slavic declension systems.',
    },
    this.culturalIslamicLexicon = const {
      'สวัสดี / ซะลาม': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'ขอบคุณ / ขอบคุณมาก': 'Danke / Vielen Dank',
      'กรุณา / โปรด': 'Bitte',
      'หนังสือ / คัมภีร์': 'Buch (Arabic: كتاب)',
      'โรงเรียน / ปอเนาะ': 'Schule / Bildungsstätte (Malay: pondok)',
      'ครู / อาจารย์': 'Lehrer / Dozent',
      'ความรู้ / วิทยาศาสตร์': 'Wissen / Wissenschaft',
      'ความยุติธรรม': 'Gerechtigkeit',
      'ละหมาด / นมาซ': 'Gebet / Salāt (Persian: نماز)',
      'ฮาลาล': 'Erlaubt / Halal (Arabic: حلال)',
      'เพื่อน / มิตร': 'Freund',
      'น้ำ': 'Wasser',
      'ขนมปัง': 'Brot / Nahrung (Portuguese loan: pão)',
      'บ้าน': 'Haus / Heim',
      'เมือง': 'Stadt',
      'โรงพยาบาล': 'Krankenhaus',
      'ร้านขายยา': 'Apotheke',
      'มัสยิด / สุเหร่า': 'Moschee (Arabic: مسجد)',
    },
    this.coreA1Vocabulary = const {
      'สวัสดี': 'Hallo / Guten Tag',
      'สวัสดีตอนเช้า': 'Guten Morgen',
      'สวัสดีตอนบ่าย': 'Guten Tag',
      'สวัสดีตอนเย็น': 'Guten Abend',
      'ขอบคุณมาก': 'Vielen Dank',
      'กรุณา': 'Bitte',
      'ใช่': 'Ja',
      'ไม่ใช่': 'Nein',
      'ฉันชื่อ / ผมชื่อ ...': 'Mein Name ist ...',
      'คุณมาจากที่ไหน?': 'Woher kommen Sie?',
      'ฉัน/ผม มาจาก ...': 'Ich komme aus ...',
      'น้ำ': 'Wasser',
      'ขนมปัง': 'Brot',
      'โรงพยาบาล': 'Krankenhaus',
      'ร้านขายยา': 'Apotheke',
      'สถานีรถไฟ': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'thai': 'สวัสดีครับ/ค่ะ! คุณพูดภาษาเยอรมันได้ไหม?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'thai': 'ใช่ครับ/ค่ะ ตอนนี้ฉันกำลังเรียนภาษาเยอรมันอยู่',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'thai': 'ขอโทษนะครับ/ค่ะ ร้านขายยาที่ใกล้ที่สุดอยู่ที่ไหน?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'thai': 'ขอบคุณมากสำหรับความช่วยเหลือของคุณ!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
