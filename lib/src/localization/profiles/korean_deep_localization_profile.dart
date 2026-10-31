import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Korean (한국어 / Hangugeo).
///
/// Koreanic language spoken by 80M+ people. Characterized by scientific Hangul
/// orthography, strict SOV sentence structure (verb-final mirror to German subordinate
/// clauses), Josa postpositional case particles (i/ga, eul/reul, ege, ui) mapping to
/// German 4 cases, and speech honorific levels matching German formal 'Sie' vs 'du'.
@immutable
class KoreanDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final bool isAgglutinative;
  final bool hasSOVVerbFinal; // Verb-final like German subordinate clauses!
  final String wordOrder;
  final Map<String, String> josaCaseParticleAlignment;
  final Map<String, String> honorificSpeechLevels;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const KoreanDeepLocalizationProfile({
    this.languageName = 'Korean',
    this.autonym = '한국어',
    this.iso6391 = 'ko',
    this.iso6392 = 'kor',
    this.languageFamily = 'Koreanic',
    this.branch = 'Korean',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Hangul (한글)',
    this.isAgglutinative = true,
    this.hasSOVVerbFinal = true,
    this.wordOrder = 'SOV (Strict Verb-Final)',
    this.josaCaseParticleAlignment = const {
      '이/가 (i/ga - Subject) & 은/는 (eun/neun - Topic)': 'Nominative subject markers (그가 읽는다). Directly maps to German Nominativ (er liest).',
      '을/를 (eul/reul - Direct Object)': 'Accusative object markers (책을 읽는다). Directly maps to German Akkusativ (das Buch lesen).',
      '에게/한테 (ege/hante - Recipient) & 에 (e - Direction/Time)': 'Dative recipient/direction markers (그에게 책을 준다). Directly maps to German Dativ (ihm das Buch geben).',
      '의 (ui - Genitive Possessive)': 'Possessive connector (선생님의 책). Directly maps to German Genitiv (das Buch des Lehrers).',
      '(으)로 ((eu)ro - Instrument / Direction)': 'Instrument or direction (버스로 가다). Maps to German Dativ with preposition "mit".',
      '에서 (eseo - Dynamic Location / Source)': 'Location of action or origin (독일에서 왔다). Maps to German prepositions "in" and "aus".',
    },
    this.honorificSpeechLevels = const {
      'Haeyoche (해요체 - Polite informal)': 'Daily respectful style. Directly anchors German formal "Sie" address in standard interactions.',
      'Hasipsioche (하십시오체 - Formal polite)': 'Highest formal register. Bridges to German courteous subjunctive (könnten Sie bitte...).',
      'Banmal (반말 - Casual informal)': 'Plain speech style. Maps directly to German informal "du" among close friends and family.',
    },
    this.culturalIslamicLexicon = const {
      '안녕하세요 / 살람': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      '감사합니다 / 고맙습니다': 'Danke / Vielen Dank',
      '부탁합니다 / 제발': 'Bitte / Bitte sehr',
      '책': 'Buch',
      '학교': 'Schule',
      '선생님': 'Lehrer / Dozent',
      '지식 / 과학': 'Wissen / Wissenschaft',
      '정의': 'Gerechtigkeit',
      '예배 / 살라트': 'Gebet / Salāt (Arabic: صلاة)',
      '할랄': 'Erlaubt / Halal (Arabic: حلال)',
      '친구': 'Freund',
      '물': 'Wasser',
      '빵': 'Brot / Nahrung (Portuguese loan: pão)',
      '집': 'Haus / Heim',
      '도시': 'Stadt',
      '병원': 'Krankenhaus',
      '약국': 'Apotheke',
      '이슬람 사원 / 모스크': 'Moschee (Arabic: جامع / مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct match to Korean "시/쉬" (/ɕi/ / /ʃ/) (시간, 쉬다 match Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Korean "ㅊ" (/tʃʰ/) (차, 친구 match Deutschland!).',
      'ch /x/ (ach-Laut)': 'Mapped via Korean aspirated velar "ㅋ" with fricative release or "ㅎ" (Bach, Nacht).',
      'z /ts/': 'German "z" is an affricate /ts/, practiced as the compound sequence "ㅌ+ㅅ" or aspirated "ㅊ" with dental friction (Zeit -> Tsait).',
      'Subordinate Verb-Final Bridge': 'Korean learners intuitively master German subordinate clause verb-final placement (weil ich Deutsch lerne) because Korean is natively SOV with verbs always at the end!',
      'Epenthesis Mitigation': 'Korean syllable constraints (CVC max) lead to vowel insertion before consonant clusters; drills eliminate intrusive vowels (avoiding *seupocheu* for *Sport*).',
    },
    this.coreA1Vocabulary = const {
      '안녕하세요': 'Hallo / Guten Tag',
      '좋은 아침입니다': 'Guten Morgen',
      '좋은 오후입니다': 'Guten Tag',
      '좋은 저녁입니다': 'Guten Abend',
      '대단히 감사합니다': 'Vielen Dank',
      '부탁합니다': 'Bitte',
      '네': 'Ja',
      '아니요': 'Nein',
      '제 이름은 ... 입니다': 'Mein Name ist ...',
      '어디에서 오셨습니까?': 'Woher kommen Sie?',
      '저는 ... 에서 왔습니다': 'Ich komme aus ...',
      '물': 'Wasser',
      '빵': 'Brot',
      '병원': 'Krankenhaus',
      '약국': 'Apotheke',
      '기차역': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'korean': '안녕하세요! 독일어를 할 줄 아십니까?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'korean': '네, 저는 지금 독일어를 배우고 있습니다.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'korean': '실례지만, 가장 가까운 약국이 어디에 있습니까?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'korean': '도와주셔서 대단히 감사합니다!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Korean Josa particle into its German case equivalent.
  String? getGermanCaseBridge(String josaName) {
    for (final entry in josaCaseParticleAlignment.entries) {
      if (entry.key.toLowerCase().contains(josaName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
