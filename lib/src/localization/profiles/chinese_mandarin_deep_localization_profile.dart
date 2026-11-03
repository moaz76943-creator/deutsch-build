import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Chinese Mandarin (普通话 / 中文).
///
/// Sinitic language spoken by 1.1B+ people. Characterized by isolating/analytic
/// morphology, 4 lexical tones, Hanzi writing with Pinyin, TeKaMoLo temporal-locative
/// adverbial parallels (Time-Place-Verb), exact 1:1 match of Pinyin 'C' to German 'Z' (/ts/),
/// and native Pinyin 'Ü/ü' (/y/) matching German 'ü' with 100% precision.
@immutable
class ChineseMandarinDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final bool isIsolating;
  final bool hasTones;
  final bool hasNativeGermanUSound; // Pinyin 'ü' = German 'ü' (/y/)!
  final bool hasNativeGermanZSound; // Pinyin 'c' = German 'z' (/ts/)!
  final String wordOrder;
  final Map<String, String> tekamoloSyntacticBridge;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const ChineseMandarinDeepLocalizationProfile({
    this.languageName = 'Chinese Mandarin',
    this.autonym = '普通话 / 中文',
    this.iso6391 = 'zh',
    this.iso6392 = 'zho',
    this.languageFamily = 'Sino-Tibetan',
    this.branch = 'Sinitic',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Simplified Chinese (简体中文) / Pinyin',
    this.isIsolating = true,
    this.hasTones = true,
    this.hasNativeGermanUSound = true, // 'ü' in lǜ, nǚ, qù = German 'ü'!
    this.hasNativeGermanZSound = true, // 'c' in cài, cóng = German 'z' (/ts/)!
    this.wordOrder = 'SVO / Topic-prominent',
    this.tekamoloSyntacticBridge = const {
      'Temporal-Locative Order (时间-地点-动词)': 'Mandarin naturally places time and location before the verb (我明天在柏林学习). This provides an effortless cognitive anchor for German TeKaMoLo: Temporal -> Kausal -> Modal -> Lokal.',
      'Topic-Comment Structure (主题-说明)': 'Mandarin topic fronting mirrors German topicalization in V2 clauses (这本书我看过了 = Dieses Buch habe ich schon gelesen).',
    },
    this.caseSystemAlignment = const {
      'Nominativ (主格 - 主语)': 'Unmarked subject position. Maps to German Nominativ (这个人学习).',
      'Akkusativ (宾格 - 宾语 / 把字句)': 'Direct object or "bǎ" disposal construction (把书看完了). Maps to German Akkusativ (das Buch).',
      'Dativ (与格 - 给 / 对)': 'Coverb "gěi" (给) marking recipient (我给他一本书). Directly maps to German Dativ (ich gebe ihm ein Buch).',
      'Genitiv (属格 - 的)': 'Particle "de" (的) marking possession (老师的书). Directly maps to German Genitiv (das Buch des Lehrers).',
      'Instrumentalis (用 / 和)': 'Coverb "yòng" (用) or "hé" (和). Maps to German Dativ with preposition "mit".',
      'Lokativ (在 ... 里/上)': 'Coverb frame "zài ... lǐ/shàng". Maps to German Dativ with prepositions "in" and "auf".',
    },
    this.culturalIslamicLexicon = const {
      '你好 / 色兰': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      '谢谢 / 非常感谢': 'Danke / Vielen Dank',
      '请 / 不客气': 'Bitte / Gern geschehen',
      '书 / 经典': 'Buch (Arabic: كتاب)',
      '学校 / 经字堂': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      '老师 / 阿訇': 'Lehrer / Gelehrter (Persian: آخوند)',
      '知识 / 科学': 'Wissen / Wissenschaft (Arabic: علم)',
      '正义 / 公道': 'Gerechtigkeit (Arabic: عدالة)',
      '礼拜 / 乃玛孜': 'Gebet / Salāt (Persian: نماز)',
      '清真 / 哈俩里': 'Erlaubt / Halal (Arabic: حلال)',
      '朋友': 'Freund',
      '水': 'Wasser',
      '面包 / 馍馍': 'Brot / Nahrung',
      '家 / 住所': 'Haus / Heim',
      '城市': 'Stadt',
      '医院': 'Krankenhaus',
      '药店': 'Apotheke',
      '清真寺': 'Moschee (Arabic: جامع / مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Mandarin Pinyin "C / c" is strictly /ts/ (e.g. cài, cān, cóng), matching German "z" (Zeit, Zug, Zimmer) with zero distortion!',
      'ü /y/': '100% Native Identity! Mandarin Pinyin "Ü / ü" is strictly /y/ (e.g. lǜ, nǚ, qù, xué), matching German "ü" (über, fünf, Tür) flawlessly!',
      'sch /ʃ/': 'Direct 1:1 match to Mandarin Pinyin "Sh / sh" (/ʂ/) (shū, shàng, Schule, schön).',
      'ch /x/ (ach-Laut)': 'Direct match to Mandarin Pinyin "H / h" before back vowels (/x/ as in hē, hǎo, Bach, Nacht).',
      'ch /ç/ (ich-Laut)': 'Direct match to Mandarin Pinyin "X / x" (/ɕ/) (xī, xiè, ich, nicht, möchte).',
      'Article System Drill': 'Because Mandarin lacks grammatical articles and gender, learners receive dedicated cognitive anchoring for der, die, das.',
    },
    this.coreA1Vocabulary = const {
      '你好': 'Hallo / Guten Tag',
      '早上好': 'Guten Morgen',
      '下午好': 'Guten Tag',
      '晚上好': 'Guten Abend',
      '非常感谢': 'Vielen Dank',
      '请': 'Bitte',
      '是 / 对': 'Ja',
      '不是 / 不': 'Nein',
      '我叫 ...': 'Mein Name ist ...',
      '你来自哪里？': 'Woher kommen Sie?',
      '我来自 ...': 'Ich komme aus ...',
      '水': 'Wasser',
      '面包': 'Brot',
      '医院': 'Krankenhaus',
      '药店': 'Apotheke',
      '火车站': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'chinese': '您好！您会说德语吗？',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'chinese': '是的，我现在正在学习德语。',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'chinese': '请问，最近的药店在哪里？',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'chinese': '非常感谢您的帮助！',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Chinese structural relation into its German case equivalent.
  String? getGermanCaseBridge(String relationName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(relationName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
