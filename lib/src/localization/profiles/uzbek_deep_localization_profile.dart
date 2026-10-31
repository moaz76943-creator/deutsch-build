import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Uzbek (O'zbek tili).
///
/// Turkic language family (Karluk branch) spoken by 35M+ people.
/// Characterized by agglutinative morphology, 6 grammatical cases,
/// SOV sentence structure (bridging with German subordinate clause V-final),
/// and historic convergence with Persian/Arabic scholarship.
@immutable
class UzbekDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool isAgglutinative;
  final bool hasVowelHarmony;
  final bool hasGrammaticalGender;
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const UzbekDeepLocalizationProfile({
    this.languageName = 'Uzbek',
    this.autonym = "O'zbek tili",
    this.iso6391 = 'uz',
    this.iso6392 = 'uzb',
    this.languageFamily = 'Turkic',
    this.branch = 'Karluk (Chagatai)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Latin (official) / Cyrillic',
    this.specialCharacters = const ["o'", "g'", "sh", "ch", "ng"],
    this.isAgglutinative = true,
    this.hasVowelHarmony = false, // neutralized due to historical Persian contact
    this.hasGrammaticalGender = false,
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'Bosh kelishik (Nominativ)': 'Unmarked base form (kitob). Mapped to German Nominativ (das Buch).',
      'Qaratqich kelishik (Genitiv)': 'Suffix -ning (kitobning). Mapped to German Genitiv (des Buches).',
      'Tushum kelishik (Akkusativ)': 'Suffix -ni (kitobni). Mapped to German definite Akkusativ (das Buch / den Mann).',
      'Joʻnalish kelishik (Dativ / Allativ)': 'Suffix -ga/-ka/-qa (maktabga). Mapped to German Dativ and direction prepositions (nach, zu).',
      'Oʻrin-payt kelishik (Lokativ)': 'Suffix -da (maktabda). Mapped to German Dativ with static location prepositions (in, an, bei).',
      'Chiqish kelishik (Ablativ)': 'Suffix -dan (maktabdan). Mapped to German Dativ with separation prepositions (aus, von, ab).',
    },
    this.culturalIslamicLexicon = const {
      'salom': 'Friede / Begrüßung (Arabic: سلام)',
      'rahmat': 'Danke / Barmherzigkeit (Arabic: رحمة)',
      'marhamat': 'Bitte / Gern geschehen (Arabic: مرحمة)',
      'kitob': 'Buch (Arabic: كتاب)',
      'maktab': 'Schule (Arabic: مكتب)',
      'muallim': 'Lehrer (Arabic: معلم)',
      'ilm': 'Wissen / Wissenschaft (Arabic: علم)',
      'adolat': 'Gerechtigkeit (Arabic: عدالة)',
      'namoz': 'Gebet (Persian/Arabic: نماز / صلاة)',
      'halol': 'Halal / Rein (Arabic: حلال)',
      'ehson': 'Wohltätigkeit / Güte (Arabic: إحسان)',
      'vaqt': 'Zeit (Arabic: وقت)',
      'oila': 'Familie (Arabic: عائلة)',
      'shahar': 'Stadt (Persian: شهر)',
      'do\'st': 'Freund (Persian: دوست)',
    },
    this.germanPhoneticBridges = const {
      'ö /ø/ & ü /y/': 'Standard Uzbek lacks official ö/ü letters; learners map them via lip rounding starting from /e/ and /i/.',
      'ch /ç/ (ich-Laut)': 'Contrasted with Uzbek "x" /χ/ and "h" /h/; articulation moved forward to hard palate.',
      'ch /x/ (ach-Laut)': 'Directly corresponds to Uzbek "x" (e.g., xat, yaxshi, Bach, Nacht).',
      'z /ts/': 'Uzbek "z" is voiced /z/; German "z" is an affricate /ts/, practiced as "t+s" cluster.',
      'Consonant Clusters': 'Uzbek tends to avoid complex initial clusters (Sprache, Straße); training focuses on fluent onset articulation without epenthetic vowels.',
    },
    this.coreA1Vocabulary = const {
      'Assalomu alaykum': 'Guten Tag / Friede sei mit Ihnen',
      'Va alaykum assalom': 'Antwort auf Begrüßung',
      'Xayrli tong': 'Guten Morgen',
      'Xayrli kun': 'Guten Tag',
      'Katta rahmat': 'Vielen Dank',
      'Iltimos / Marhamat': 'Bitte',
      'Ha': 'Ja',
      'Yo\'q': 'Nein',
      'Mening ismim': 'Mein Name ist',
      'Qayerdansiz?': 'Woher kommen Sie?',
      'Men ... danman': 'Ich komme aus ...',
      'Suv': 'Wasser',
      'Non': 'Brot',
      'Dorixona': 'Apotheke',
      'Shifoxona': 'Krankenhaus',
      'Vokzal': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'uzbek': 'Assalomu alaykum! Siz nemischa gapirasizmi?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'السلام عليكم! هل تتحدث الألمانية؟',
      },
      {
        'uzbek': 'Ha, men hozir nemis tilini o\'rganyapman.',
        'german': 'Ja, ich lerne gerade Deutsch.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'uzbek': 'Bu yerda dorixona qayerda joylashgan?',
        'german': 'Wo befindet sich hier die Apotheke?',
        'arabic': 'أين تقع الصيدلية هنا؟',
      },
      {
        'uzbek': 'Katta rahmat, yordamingiz uchun!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates Uzbek grammatical case to its corresponding German case/preposition.
  String? getGermanCaseBridge(String uzbekCaseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(uzbekCaseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }

  /// Verifies if a word belongs to the shared Islamic/cultural lexicon.
  bool isSharedCulturalTerm(String term) {
    return culturalIslamicLexicon.containsKey(term.toLowerCase().trim());
  }
}
