import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Lao (ພາສາລາວ / Phasa Lao).
///
/// Kra-Dai language (Southwestern Tai branch) spoken by 30M+ people in Laos and
/// the Isan region of Thailand. Characterized by Lao script (27 consonants, 28 vowel forms),
/// 6 phonemic tones, isolating SVO syntax, numeral classifiers, and omnidirectional
/// cross-lingual alignment across Southeast Asian and European languages.
@immutable
class LaoDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final int toneCount;
  final Map<String, String> isolatingCaseBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const LaoDeepLocalizationProfile({
    this.languageName = 'Lao',
    this.autonym = 'ພາສາລາວ',
    this.iso6391 = 'lo',
    this.iso6392or3 = 'lao',
    this.typology = TypologicalClassification.isolatingAnalytic,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.analyticalPrepositional,
    this.hasTones = true,
    this.hasGrammaticalGender = false,
    this.writingDirection = 'ltr',
    this.primaryScript = 'Lao script (ອັກສອນລາວ)',
    this.toneCount = 6, // Low, Mid, High, Rising, High Falling, Low Falling
    this.isolatingCaseBridge = const {
      'Nominativ (Subject)': 'Unmarked subject in SVO (ຜູ້ຊາຍອ່ານ). Maps to German Nominativ (der Mann liest).',
      'Akkusativ (Direct Object)': 'Direct object following verb (ອ່ານປຶ້ມ). Maps to German Akkusativ (das Buch lesen).',
      'Dativ (Recipient - ໃຫ້ / ដល់)': 'Preposition "hai" or "deng" (ໃຫ້ຜູ້ຊາຍ). Maps to German Dativ (dem Mann geben).',
      'Genitiv (Possessive - ຂອງ)': 'Preposition "khong" (ປຶ້ມຂອງຄູ). Directly maps to German Genitiv (das Buch des Lehrers).',
      'Instrumentalis (ດ້ວຍ)': 'Preposition "duay" (ດ້ວຍລົດ). Maps to German Dativ with preposition "mit".',
      'Lokativ (ໃນ / ຢູ່)': 'Prepositions "nai", "yu" (ໃນເມືອງ). Maps to German Dativ with prepositions "in" and "an".',
    },
    this.culturalIslamicLexicon = const {
      'ສະບາຍດີ / ຊາລາມ': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'ຂອບໃຈ / ຂອບໃຈຫຼາຍໆ': 'Danke / Vielen Dank',
      'ກະລຸນາ / ໂປດ': 'Bitte',
      'ປຶ້ມ / ຄຳພີ': 'Buch (Arabic: كتاب)',
      'ໂຮງຮຽນ / ມາດຣາຊາ': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'ຄູ / ອາຈານ': 'Lehrer / Dozent',
      'ຄວາມຮູ້ / ວິທະຍາສາດ': 'Wissen / Wissenschaft',
      'ຄວາມຍຸຕິທຳ': 'Gerechtigkeit',
      'ການອະທິຖານ / ຊະລາດ': 'Gebet / Salāt (Arabic: صلاة)',
      'ຮາລານ': 'Erlaubt / Halal (Arabic: حلال)',
      'ໝູ່ / ເພື່ອນ': 'Freund',
      'ນ້ຳ': 'Wasser',
      'ເຂົ້າຈີ່': 'Brot / Baguette / Nahrung',
      'ເຮືອນ': 'Haus / Heim',
      'ເມືອງ': 'Stadt',
      'ໂຮງໝໍ': 'Krankenhaus',
      'ຮ້ານຂາຍຢາ': 'Apotheke',
      'ມັດສະຍິດ': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Practiced via postalveolar articulation contrasting with Lao alveolar /s/.',
      'tsch /tʃ/': 'Direct 1:1 match to Lao "ຈ" (/tɕ/) (Deutschland).',
      'z /ts/': 'German "z" is an affricate /ts/, practiced as compound "ຕ+ສ" (tsunami -> Zeit).',
      'ch /x/ (ach-Laut)': 'Mapped via velar release contrasting with Lao aspirated consonants.',
      '6-Tone Acoustic Acuity': 'Lao speakers leverage their 6-tone pitch control to master German expressive prosody and sentence melody.',
    },
    this.coreA1Vocabulary = const {
      'ສະບາຍດີ': 'Hallo / Guten Tag',
      'ສະບາຍດີຕອນເຊົ້າ': 'Guten Morgen',
      'ສະບາຍດີຕອນສວາຍ': 'Guten Tag',
      'ສະບາຍດີຕອນແລງ': 'Guten Abend',
      'ຂອບໃຈຫຼາຍໆ': 'Vielen Dank',
      'ກະລຸນາ': 'Bitte',
      'ແມ່ນ / ເຈົ້າ': 'Ja',
      'ບໍ່ / ບໍ່ແມ່ນ': 'Nein',
      'ຂ້ອຍຊື່ ...': 'Mein Name ist ...',
      'ເຈົ້າມາຈາກໃສ?': 'Woher kommen Sie?',
      'ຂ້ອຍມາຈາກ ...': 'Ich komme aus ...',
      'ນ້ຳ': 'Wasser',
      'ເຂົ້າຈີ່': 'Brot',
      'ໂຮງໝໍ': 'Krankenhaus',
      'ຮ້ານຂາຍຢາ': 'Apotheke',
      'ສະຖານີລົດໄຟ': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'lao': 'ສະບາຍດີ! ເຈົ້າເວົ້າພາສາເຢຍລະມັນໄດ້ບໍ່?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'lao': 'ເຈົ້າ, ຂ້ອຍກຳລັງຮຽນພາສາເຢຍລະມັນຕອນນີ້.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'lao': 'ກະລຸນາບອກຂ້ອຍ, ຮ້ານຂາຍຢາທີ່ໃກ້ທີ່ສຸດຢູ່ໃສ?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'lao': 'ຂອບໃຈຫຼາຍໆສຳລັບການຊ່ວຍເຫຼືອຂອງທ່ານ!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
