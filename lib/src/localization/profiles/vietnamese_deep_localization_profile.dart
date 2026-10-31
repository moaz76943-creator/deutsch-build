import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Vietnamese (Tiếng Việt).
///
/// Austroasiatic language (Vietic branch) spoken by 90M+ people. Characterized by
/// Latin-based Chữ Quốc ngữ orthography, 6 lexical tones, isolating/analytic syntax,
/// SVO word order, deep Sino-Vietnamese cognate inventory (Hán-Việt) for Asian cross-mapping,
/// and omnidirectional bridges across both isolating and fusional languages.
@immutable
class VietnameseDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
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
  final List> practicalDialoguePhrases;

  const VietnameseDeepLocalizationProfile({
    this.languageName = 'Vietnamese',
    this.autonym = 'Tiếng Việt',
    this.iso6391 = 'vi',
    this.iso6392or3 = 'vie',
    this.typology = TypologicalClassification.isolatingAnalytic,
    this.primaryWordOrder = CanonicalWordOrder.svo,
    this.alignment = GrammaticalAlignment.analyticalPrepositional,
    this.hasTones = true,
    this.hasGrammaticalGender = false,
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (Chữ Quốc ngữ with tone marks)',
    this.toneRegisters = const ['Ngang (Mid level)', 'Huyền (Low falling)', 'Sắc (High rising)', 'Hỏi (Dipping-rising)', 'Ngã (High broken)', 'Nặng (Low constricted)'],
    this.omnidirectionalBridges = const {
      'Sino-Vietnamese Bridge (Hán-Việt)': 'Massive shared lexical root inventory with Chinese, Japanese, and Korean (e.g., quốc gia = 국가 = 国家 = Staat/Nation).',
      'Southeast Asian Isolating Bridge': 'Seamless 1:1 syntactic alignment with Thai, Lao, and Malay/Indonesian in isolating SVO structure.',
      'Western Fusional Bridge (German/Romance)': 'Isolating particles (của = Genitiv, cho = Dativ, với = mit) map directly into fusional case and prepositional systems.',
    },
    this.culturalIslamicLexicon = const {
      'xin chào / salam': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'cảm ơn / cảm ơn rất nhiều': 'Danke / Vielen Dank',
      'làm ơn / xin vui lòng': 'Bitte',
      'sách': 'Buch',
      'trường học / trường tôn giáo': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'thầy giáo / cô giáo': 'Lehrer / Lehrerin',
      'kiến thức / khoa học': 'Wissen / Wissenschaft',
      'công lý / công bằng': 'Gerechtigkeit',
      'cầu nguyện / salat': 'Gebet / Salāt (Arabic: صلاة)',
      'halal / hợp giáo quy': 'Erlaubt / Halal (Arabic: حلال)',
      'bạn bè / bạn': 'Freund',
      'nước': 'Wasser',
      'bánh mì': 'Brot / Nahrung',
      'nhà': 'Haus / Heim',
      'thành phố': 'Stadt',
      'bệnh viện': 'Krankenhaus',
      'hiệu thuốc': 'Apotheke',
      'thánh đường / nhà thờ hồi giáo': 'Moschee (Arabic: مسجد)',
    },
    this.coreA1Vocabulary = const {
      'Xin chào': 'Hallo / Guten Tag',
      'Chào buổi sáng': 'Guten Morgen',
      'Chào buổi chiều': 'Guten Tag',
      'Chào buổi tối': 'Guten Abend',
      'Cảm ơn rất nhiều': 'Vielen Dank',
      'Làm ơn': 'Bitte',
      'Vâng / Có': 'Ja',
      'Không': 'Nein',
      'Tên tôi là ...': 'Mein Name ist ...',
      'Bạn từ đâu đến?': 'Woher kommen Sie?',
      'Tôi đến từ ...': 'Ich komme aus ...',
      'Nước': 'Wasser',
      'Bánh mì': 'Brot',
      'Bệnh viện': 'Krankenhaus',
      'Hiệu thuốc': 'Apotheke',
      'Ga xe lửa': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'vietnamese': 'Xin chào! Bạn có nói tiếng Đức không?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'vietnamese': 'Có, tôi hiện đang học tiếng Đức.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'vietnamese': 'Làm ơn cho tôi hỏi, hiệu thuốc gần nhất ở đâu?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'vietnamese': 'Cảm ơn bạn rất nhiều vì sự giúp đỡ!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });
}
