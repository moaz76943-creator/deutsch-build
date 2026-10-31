import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Japanese (日本語 / Nihongo).
///
/// Japonic language spoken by 125M+ people. Characterized by strict SOV sentence
/// architecture directly mirroring German subordinate clause verb-final placement,
/// case particles (ga, o, ni, no) mapping to German 4 cases, Keigo politeness levels
/// matching German formal 'Sie' vs 'du', and native 'tsu' matching German 'z' (/ts/).
@immutable
class JapaneseDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final List<String> scripts; // Kanji, Hiragana, Katakana
  final bool isAgglutinative;
  final bool hasSOVVerbFinal; // Verb-final like German subordinate clauses!
  final String wordOrder;
  final Map<String, String> particleCaseAlignment;
  final Map<String, String> keigoHonorificBridge;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const JapaneseDeepLocalizationProfile({
    this.languageName = 'Japanese',
    this.autonym = '日本語',
    this.iso6391 = 'ja',
    this.iso6392 = 'jpn',
    this.languageFamily = 'Japonic',
    this.branch = 'Japanese',
    this.writingDirection = 'ltr',
    this.scripts = const ['Kanji (漢字)', 'Hiragana (ひらがな)', 'Katakana (カタカナ)'],
    this.isAgglutinative = true,
    this.hasSOVVerbFinal = true,
    this.wordOrder = 'SOV (Strict Verb-Final)',
    this.particleCaseAlignment = const {
      'が (ga - Subject) / は (wa - Topic)': 'Nominative subject marker (彼が読む). Directly maps to German Nominativ (er liest).',
      'を (o - Direct Object)': 'Accusative patient marker (本を読む). Directly maps to German Akkusativ (das Buch lesen).',
      'に (ni - Indirect Object / Destination)': 'Dative recipient/direction marker (彼に本をあげる). Directly maps to German Dativ (ihm das Buch geben).',
      'の (no - Genitive Possessive)': 'Possessive connector (先生の本). Directly maps to German Genitiv (das Buch des Lehrers).',
      'で (de - Instrumental / Location)': 'Means or event location (バスで行く). Maps to German Dativ with preposition "mit".',
      'から (kara - Source) / まで (made - Goal)': 'Source and goal markers. Maps to German prepositions "aus/von" and "bis/nach".',
    },
    this.keigoHonorificBridge = const {
      'Teineigo (丁寧語 - です/ます)': 'Standard polite style. Directly anchors German formal polite "Sie" address.',
      'Sonkeigo (尊敬語 - お/ご...になる)': 'Respectful honorifics. Bridges to German courteous subjunctive (könnten Sie bitte...).',
      'Tameguchi (タメ口 - だ/Plain)': 'Informal casual speech. Maps directly to German informal "du" among friends and family.',
    },
    this.culturalIslamicLexicon = const {
      'こんにちは / セラーム': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'ありがとう / ありがとうございます': 'Danke / Vielen Dank',
      'お願いします / どうぞ': 'Bitte / Bitte sehr',
      '本': 'Buch',
      '学校': 'Schule',
      '先生 / 教師': 'Lehrer / Dozent',
      '知識 / 科学': 'Wissen / Wissenschaft',
      '正義': 'Gerechtigkeit',
      '礼拝 / ナマズ': 'Gebet / Salāt (Persian: نماز)',
      'ハラール': 'Erlaubt / Halal (Arabic: حلال)',
      '友達 / 友人': 'Freund',
      '水': 'Wasser',
      'パン': 'Brot / Nahrung (Portuguese loan: pão)',
      '家 / 自宅': 'Haus / Heim',
      '都市 / 町': 'Stadt',
      '病院': 'Krankenhaus',
      '薬局': 'Apotheke',
      'モスク / 寺院': 'Moschee (Arabic: جامع / مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Japanese "Ts / つ" is strictly /ts/ (tsunami, tsuki), matching German "z" (Zeit, Zug, Zimmer) with zero distortion!',
      'sch /ʃ/': 'Direct 1:1 match to Japanese "Sh / し" (/ɕ/) (shimbun, sushi, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Japanese "Ch / ち" (/tʃ/) (cha, chizu, Deutschland).',
      'Subordinate Verb-Final Bridge': 'Japanese speakers effortlessly master German subordinate clause verb-final placement (weil ich Deutsch lerne) because Japanese is natively SOV with verbs always at the end!',
      'Epenthesis Mitigation': 'Japanese is mora-timed with open syllables; dedicated exercises eliminate intrusive epenthetic vowels (avoiding *sutorāse* for *Straße*, *supōtsu* for *Sport*).',
    },
    this.coreA1Vocabulary = const {
      'こんにちは': 'Hallo / Guten Tag',
      'おはようございます': 'Guten Morgen',
      'こんにちは (午後)': 'Guten Tag',
      'こんばんは': 'Guten Abend',
      'ありがとうございます': 'Vielen Dank',
      'お願いします': 'Bitte',
      'はい': 'Ja',
      'いいえ': 'Nein',
      '私の名前は ... です': 'Mein Name ist ...',
      'ご出身はどちらですか？': 'Woher kommen Sie?',
      '私は ... の出身です': 'Ich komme aus ...',
      '水': 'Wasser',
      'パン': 'Brot',
      '病院': 'Krankenhaus',
      '薬局': 'Apotheke',
      '駅': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'japanese': 'こんにちは！ドイツ語を話せますか？',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'japanese': 'はい、私は今ドイツ語を勉強しています。',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'japanese': 'すみません、一番近い薬局はどこですか？',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'japanese': '手伝っていただき、どうもありがとうございました！',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Japanese particle into its German case equivalent.
  String? getGermanCaseBridge(String particleName) {
    for (final entry in particleCaseAlignment.entries) {
      if (entry.key.toLowerCase().contains(particleName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
