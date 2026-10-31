import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Kannada (ಕನ್ನಡ).
///
/// Major Southern Dravidian language spoken by 45M+ people in Karnataka.
/// Features rounded Brahmic script, SOV clause structure, agglutinative 7-case
/// Vibhakti system, natural 3-gender pronominal alignment (avanu/avalu/adu matching er/sie/es),
/// and a two-tier honorific system (neenu vs neevu matching German du vs Sie).
@immutable
class KannadaDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final bool isAgglutinative;
  final bool hasFormalPronounDistinction; // neenu (du) vs neevu (Sie)
  final String wordOrder;
  final Map<String, String> pronominalGenderBridge;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const KannadaDeepLocalizationProfile({
    this.languageName = 'Kannada',
    this.autonym = 'ಕನ್ನಡ',
    this.iso6391 = 'kn',
    this.iso6392 = 'kan',
    this.languageFamily = 'Dravidian',
    this.branch = 'Southern Dravidian',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Kannada script',
    this.isAgglutinative = true,
    this.hasFormalPronounDistinction = true,
    this.wordOrder = 'SOV',
    this.pronominalGenderBridge = const {
      'Avanu (ಅವನು)': 'German "er" (Maskulinum - 3rd person singular masculine).',
      'Avalu (ಅವಳು)': 'German "sie" (Femininum - 3rd person singular feminine).',
      'Adu (ಅದು)': 'German "es" (Neutrum - 3rd person singular non-human/neuter).',
      'Neevu (ನೀವು)': 'German polite formal "Sie" (honorific address).',
      'Neenu (ನೀನು)': 'German informal "du" (familiar address).',
    },
    this.caseSystemAlignment = const {
      'Prathama (ಪ್ರಥಮಾ - ಉ)': 'Subject base form (ಹುಡುಗನು). Directly maps to German Nominativ (der Junge).',
      'Dvitiya (ದ್ವಿತೀಯಾ - ಅನ್ನು)': 'Accusative suffix -annu (ಪುಸ್ತಕವನ್ನು). Directly maps to German Akkusativ (das Buch).',
      'Tritiya (ತೃತೀಯಾ - ಇಂದ)': 'Instrumental/Ablative suffix -inda. Maps to German Dativ with prepositions "mit" and "von/aus".',
      'Chaturthi (ಚತುರ್ಥೀ - ಗೆ/ಕ್ಕೆ)': 'Dative suffix -ge/-kke (ಶಾಲೆಗೆ). Maps to German Dativ and directional prepositions (zu, nach).',
      'Panchami (ಪಂಚಮೀ - ದೆಸೆಯಿಂದ)': 'Ablative separation suffix. Maps to German Dativ with source preposition "aus".',
      'Shashthi (ಷಷ್ಠೀ - ಅ)': 'Genitive suffix -a (ಅವನ). Matches German Genitiv (des Mannes).',
      'Saptami (ಸಪ್ತಮೀ - ಅಲ್ಲಿ)': 'Locative suffix -alli (ನಗರದಲ್ಲಿ). Matches German Dativ with static preposition "in".',
    },
    this.culturalIslamicLexicon = const {
      'ನಮಸ್ಕಾರ / ಸಲಾಂ': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'ಧನ್ಯವಾದಗಳು / ಶುಕ್ರಿಯಾ': 'Danke / Dankbarkeit (Arabic: شكراً)',
      'ದಯವಿಟ್ಟು / ಮೆಹರ್ಬಾನಿ ಮಾಡಿ': 'Bitte / Freundlichkeit (Persian: مهرباني)',
      'ಪುಸ್ತಕ / ಕಿತಾಬ್': 'Buch (Arabic: كتاب)',
      'ಶಾಲೆ / ಮಕ್ತಬ್': 'Schule (Arabic: مكتب)',
      'ಶಿಕ್ಷಕ / ಉಸ್ತಾದ್': 'Lehrer / Meister (Persian: استاد)',
      'ವಿದ್ಯೆ / ಇಲ್ಮ್': 'Wissen / Wissenschaft (Arabic: علم)',
      'ನ್ಯಾಯ / ಅದಾಲತ್': 'Gerechtigkeit (Arabic: عدالة)',
      'ನಮಾಜ್': 'Gebet / Salāt (Persian: نماز)',
      'ಹಲಾಲ್': 'Erlaubt / Halal (Arabic: حلال)',
      'ಸ್ನೇಹಿತ / ದೋಸ್ತ್': 'Freund (Persian: دوست)',
      'ನೀರು': 'Wasser',
      'ರೊಟ್ಟಿ': 'Brot / Nahrung',
      'ಮನೆ': 'Haus / Heim',
      'ನಗರ / ಶಹರ್': 'Stadt (Persian: شهر)',
      'ಆಸ್ಪತ್ರೆ': 'Krankenhaus',
      'ಔಷಧಾಲಯ': 'Apotheke',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct match to Kannada "ಶ" (e.g., ಶಾಲೆ -> Schule, schön).',
      'z /ts/': 'German affricate /ts/; practiced as compound "ತ್+ಸ್" (Zeit -> Tsait).',
      'ch /x/ (ach-Laut)': 'Mapped via velar release contrasting with Kannada aspirated "ಖ".',
      'ö /ø/ & ü /y/': 'Front rounded vowels mapped through systematic lip rounding from Kannada /e/ and /i/.',
      'Honorific Register Bridge': 'Kannada speakers intuitively grasp German "du" vs "Sie" through their native "neenu" vs "neevu" honorific system.',
    },
    this.coreA1Vocabulary = const {
      'ನಮಸ್ಕಾರ / ಸಲಾಂ': 'Hallo / Guten Tag',
      'ಶುಭೋದಯ': 'Guten Morgen',
      'ಶುಭ ಮಧ್ಯಾಹ್ನ': 'Guten Tag',
      'ಶುಭ ಸಂಜೆ': 'Guten Abend',
      'ತುಂಬಾ ಧನ್ಯವಾದಗಳು': 'Vielen Dank',
      'ದಯವಿಟ್ಟು': 'Bitte',
      'ಹೌದು': 'Ja',
      'ಇಲ್ಲ': 'Nein',
      'ನನ್ನ ಹೆಸರು ...': 'Mein Name ist ...',
      'ನೀವು ಎಲ್ಲಿಂದ ಬಂದಿದ್ದೀರಿ?': 'Woher kommen Sie?',
      'ನಾನು ... ಇಂದ ಬಂದಿದ್ದೇನೆ': 'Ich komme aus ...',
      'ನೀರು': 'Wasser',
      'ರೊಟ್ಟಿ': 'Brot',
      'ಆಸ್ಪತ್ರೆ': 'Krankenhaus',
      'ಔಷಧಾಲಯ': 'Apotheke',
      'ರೈಲ್ವೆ ನಿಲ್ದಾಣ': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'kannada': 'ನಮಸ್ಕಾರ! ನೀವು ಜರ್ಮನ್ ಮಾತನಾಡುತ್ತೀರಾ?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'kannada': 'ಹೌದು, ನಾನು ಈಗ ಜರ್ಮನ್ ಭಾಷೆಯನ್ನು ಕಲಿಯುತ್ತಿದ್ದೇನೆ.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'kannada': 'ದಯವಿಟ್ಟು ತಿಳಿಸಿ, ಹತ್ತಿರದ ಔಷಧಾಲಯ ಎಲ್ಲಿದೆ?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'kannada': 'ನಿಮ್ಮ ಸಹಾಯಕ್ಕೆ ತುಂಬಾ ಧನ್ಯವಾದಗಳು!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Kannada Vibhakti case to its German equivalent.
  String? getGermanCaseBridge(String vibhaktiName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(vibhaktiName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
