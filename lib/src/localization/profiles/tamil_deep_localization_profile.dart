import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Tamil (தமிழ்).
///
/// Classical Dravidian language spoken by 85M+ people across India, Sri Lanka,
/// Singapore, and Malaysia. Features rich agglutinative morphology, an 8-case system
/// (Veṟṟumai), SOV sentence structure, unique retroflex approximants (ழ /ɻ/, ள /ɭ/),
/// and absence of grammatical articles requiring dedicated German Der/Die/Das drills.
@immutable
class TamilDeepLocalizationProfile {
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
  final bool hasGrammaticalGenderInArticles; // false in Tamil
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const TamilDeepLocalizationProfile({
    this.languageName = 'Tamil',
    this.autonym = 'தமிழ்',
    this.iso6391 = 'ta',
    this.iso6392 = 'tam',
    this.languageFamily = 'Dravidian',
    this.branch = 'Southern Dravidian',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Tamil script',
    this.specialCharacters = const ['ழ', 'ள', 'ற', 'ண', 'ன', 'ஞ', 'ஃ'],
    this.isAgglutinative = true,
    this.hasGrammaticalGenderInArticles = false,
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'Mudhal Veṟṟumai (முதல் வேற்றுமை - எழுவாய்)': 'Unmarked nominative subject. Directly maps to German Nominativ (der Mann liest).',
      'Iraṇḍām Veṟṟumai (இரண்டாம் வேற்றுமை - ஐ)': 'Accusative suffix -ai (புத்தகத்தை). Directly maps to German Akkusativ (das Buch).',
      'Mūṉṟām Veṟṟumai (மூன்றாம் வேற்றுமை - ஆல்/உடன்)': 'Instrumental & Sociative suffix -āl/-uḍan. Matches German Dativ with preposition "mit".',
      'Nāngām Veṟṟumai (நான்காம் வேற்றுமை - கு)': 'Dative suffix -ku/-ukku (பள்ளிக்கு). Matches German Dativ and direction prepositions (zu, nach).',
      'Aindhām Veṟṟumai (ஐந்தாம் வேற்றுமை - இல்/இருந்து)': 'Ablative suffix -irundu (வீட்டிலிருந்து). Matches German Dativ with "aus" and "von".',
      'Āṟām Veṟṟumai (ஆறாம் வேற்றுமை - உடைய)': 'Genitive possessive suffix -uḍaiya (அவருடைய). Matches German Genitiv (des Mannes).',
      'Ēḻām Veṟṟumai (ஏழாம் வேற்றுமை - இல்/இடம்)': 'Locative suffix -il (நகரத்தில்). Matches German Dativ with static preposition "in".',
    },
    this.culturalIslamicLexicon = const {
      'வணக்கம் / ஸலாம்': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'நன்றி / சுக்ரியா': 'Danke / Dankbarkeit (Arabic: شكرية)',
      'தயவுசெய்து': 'Bitte',
      'புத்தகம் / கிதாப்': 'Buch (Arabic: كتاب)',
      'பள்ளிவாசல்': 'Moschee',
      'பள்ளி / மதரஸா': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'ஆசிரியர் / உஸ்தாத்': 'Lehrer / Meister (Persian: استاد)',
      'கல்வி / இல்ம்': 'Wissen / Wissenschaft (Arabic: علم)',
      'நீதி / அதாலத்': 'Gerechtigkeit (Arabic: عدالة)',
      'தொழுகை / நமாஸ்': 'Gebet / Salāt (Persian: نماز)',
      'ஹலால்': 'Erlaubt / Halal (Arabic: حلال)',
      'நண்பர்': 'Freund',
      'தண்ணீர்': 'Wasser',
      'ரொட்டி': 'Brot / Nahrung',
      'வீடு': 'Haus / Heim',
      'நகரம்': 'Stadt',
      'மருத்துவமனை': 'Krankenhaus',
      'மருந்தகம்': 'Apotheke',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Mapped to Grantha letter "ஷ" (e.g., பள்ளி -> Schule, schön).',
      'z /ts/': 'German affricate /ts/; mapped to compound "த்+ஸ்" (Zeit -> Tsait).',
      'ch /x/ (ach-Laut)': 'Mapped via velar friction using Aytham "ஃ" or softened aspirated release.',
      'ch /ç/ (ich-Laut)': 'Palatal fricative practiced without retroflexion, contrasting with Tamil dental and palatal stops.',
      'Consonant Cluster Mitigation': 'Tamil avoids initial consonant clusters; drills eliminate intrusive epenthetic vowels before "Sp-", "St-", "Sch-".',
      'Article System Drill': 'Because Tamil lacks grammatical articles, learners receive dedicated cognitive anchoring for der, die, das.',
    },
    this.coreA1Vocabulary = const {
      'வணக்கம் / ஸலாம்': 'Hallo / Guten Tag',
      'காலை வணக்கம்': 'Guten Morgen',
      'மதிய வணக்கம்': 'Guten Tag',
      'மாலை வணக்கம்': 'Guten Abend',
      'மிக்க நன்றி': 'Vielen Dank',
      'தயவுசெய்து': 'Bitte',
      'ஆம்': 'Ja',
      'இல்லை': 'Nein',
      'என் பெயர் ...': 'Mein Name ist ...',
      'நீங்கள் எங்கிருந்து வருகிறீர்கள்?': 'Woher kommen Sie?',
      'நான் ...-லிருந்து வருகிறேன்': 'Ich komme aus ...',
      'தண்ணீர்': 'Wasser',
      'ரொட்டி': 'Brot',
      'மருத்துவமனை': 'Krankenhaus',
      'மருந்தகம்': 'Apotheke',
      'தொடர்வண்டி நிலையம்': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'tamil': 'வணக்கம்! நீங்கள் ஜெர்மன் மொழி பேசுவீர்களா?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'tamil': 'ஆம், நான் இப்போது ஜெர்மன் மொழி கற்கிறேன்.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'tamil': 'தயவுசெய்து சொல்லுங்கள், அருகிலுள்ள மருந்தகம் எங்கே உள்ளது?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'tamil': 'உங்கள் உதவிக்கு மிக்க நன்றி!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates Tamil Veṟṟumai case to German case equivalent.
  String? getGermanCaseBridge(String verrumaiName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(verrumaiName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
