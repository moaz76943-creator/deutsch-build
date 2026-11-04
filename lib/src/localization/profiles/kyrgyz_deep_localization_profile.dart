import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Kyrgyz (Кыргыз тили).
///
/// Turkic language family (Kipchak-Kyrgyz branch) spoken by 6M+ people.
/// Distinguished by native umlauts (Ө/ö, Ү/ü) matching German, the most rigorous
/// 8-way labial vowel harmony among all Turkic languages, agglutinative morphology,
/// 6 grammatical cases, and SOV clause architecture.
@immutable
class KyrgyzDeepLocalizationProfile {
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
  final bool hasEightWayVowelHarmony; // Extensive rounding harmony
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const KyrgyzDeepLocalizationProfile({
    this.languageName = 'Kyrgyz',
    this.autonym = 'Кыргыз тили',
    this.iso6391 = 'ky',
    this.iso6392 = 'kir',
    this.languageFamily = 'Turkic',
    this.branch = 'Kipchak (Kipchak-Kyrgyz)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Cyrillic (official) / Arabic (diaspora)',
    this.specialCharacters = const ['Ө', 'ө', 'Ү', 'ү', 'Ң', 'ң'],
    this.isAgglutinative = true,
    this.hasEightWayVowelHarmony = true, // Strict front/back and rounded/unrounded harmony
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'Атооч жөندөмө (Nominativ)': 'Unmarked base subject form (китеп). Matches German Nominativ (das Buch).',
      'Илик жөندөмө (Genitiv)': 'Suffix -нын / -нин / -нун / -нүн (китептин). Matches German Genitiv (des Buches).',
      'Барыш жөندөмө (Dativ / Allativ)': 'Suffix -га / -ге / -го / -гө (мектепке). Matches German Dativ & prepositions (zu, nach).',
      'Табыш жөندөмө (Akkusativ)': 'Suffix -ны / -ни / -ну / -нү (китепти). Matches German definite Akkusativ (das Buch / den Mann).',
      'Жатыш жөندөмө (Lokativ)': 'Suffix -да / -де / -до / -дө (мектепте). Matches German Dativ with static prepositions (in, an).',
      'Чыгыш жөندөмө (Ablativ)': 'Suffix -дан / -ден / -дон / -дөн (мектептен). Matches German Dativ with source prepositions (aus, von).',
    },
    this.culturalIslamicLexicon = const {
      'салам / ассалому алейкум': 'Friede / Begrüßung (Arabic: سلام)',
      'чоң рахмат': 'Danke / Barmherzigkeit (Arabic: رحمة)',
      'сураныч / мархамат': 'Bitte (Arabic: مرحمة)',
      'китеп': 'Buch (Arabic: كتاب)',
      'мектеп': 'Schule (Arabic: مكتب)',
      'мугалим': 'Lehrer (Arabic: معلم)',
      'илим': 'Wissenschaft / Wissen (Arabic: علم)',
      'адилеттик': 'Gerechtigkeit (Arabic: عدالة)',
      'намаз': 'Gebet / Salāt (Persian/Arabic: نماز / صلاة)',
      'адал / халал': 'Erlaubt / Halal (Arabic: حلال)',
      'дос': 'Freund (Persian: دوست)',
      'суу': 'Wasser',
      'нан': 'Brot / Nahrung',
      'үй': 'Haus / Heim',
      'шаар': 'Stadt (Persian: شهر)',
      'оорукана': 'Krankenhaus',
      'дарыкана': 'Apotheke',
    },
    this.germanPhoneticBridges = const {
      'Ө /ө/ & Ү /ү/': '100% Native Identity! Kyrgyz "Ө" and "Ү" (көз, гүл) directly match German "ö" (schön) and "ü" (über).',
      'sch /ʃ/': 'Direct 1:1 match to Kyrgyz "ш" (шаар, Schule, schön).',
      'ch /x/ (ach-Laut)': 'Direct match to Kyrgyz "х" and uvular back "к/г" (кат, Bach, Nacht).',
      'z /ts/': 'Kyrgyz "з" is voiced /z/; German "z" is an affricate /ts/, practiced as "т+с" compound.',
      'Labial Harmony Precision': 'Kyrgyz speakers naturally master German rounded vowels through their native 8-way vowel harmony system.',
    },
    this.coreA1Vocabulary = const {
      'Салам / Ассалому алейкум': 'Hallo / Guten Tag',
      'Кутмандуу таңыңыз менен': 'Guten Morgen',
      'Кутмандуу күнүңүз менен': 'Guten Tag',
      'Кутмандуу кечиңиз менен': 'Guten Abend',
      'Чоң рахмат': 'Vielen Dank',
      'Сураныч': 'Bitte',
      'Ооба': 'Ja',
      'Жок': 'Nein',
      'Менин атым ...': 'Mein Name ist ...',
      'Сиз кайдан болосуз?': 'Woher kommen Sie?',
      'Мен ...-дан/ден болом': 'Ich komme aus ...',
      'Суу': 'Wasser',
      'Нан': 'Brot',
      'Оорукана': 'Krankenhaus',
      'Дарыкана': 'Apotheke',
      'Темир жол бекети': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'kyrgyz': 'Саламатсызбы! Сиз немисче сүйлөйсүзбү?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'kyrgyz': 'Ооба, мен азыр немис тилин үйрөнүп жатам.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'kyrgyz': 'Сураныч, эң жакын дарыкана кайда жайгашкан?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'kyrgyz': 'Жардамыңыз үчүн чоң рахмат!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Confirms that Kyrgyz natively possesses German umlauts ö and ü.
  bool hasNativeGermanUmlauts() {
    return specialCharacters.contains('Ө') && specialCharacters.contains('Ү');
  }

  /// Translates a Kyrgyz case suffix to its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
