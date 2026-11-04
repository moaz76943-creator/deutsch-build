import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Sinhala (සිංහල).
///
/// Insular Indo-Aryan language spoken by 17M+ people in Sri Lanka.
/// Features rounded Sinhala script, distinctive prenasalized stops (ඟ, ඬ, ඳ, ඹ),
/// animate vs inanimate grammatical gender split, SOV word order, and absence
/// of grammatical articles requiring structured German Der/Die/Das training.
@immutable
class SinhalaDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> prenasalizedStops;
  final bool hasAnimateInanimateDistinction;
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const SinhalaDeepLocalizationProfile({
    this.languageName = 'Sinhala',
    this.autonym = 'සිංහල',
    this.iso6391 = 'si',
    this.iso6392 = 'sin',
    this.languageFamily = 'Indo-European',
    this.branch = 'Indo-Aryan (Insular / Southern)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Sinhala script',
    this.prenasalizedStops = const ['ඟ', 'ඬ', 'ඳ', 'ඹ'],
    this.hasAnimateInanimateDistinction = true,
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'Prathama (ප්‍රථමා - Nominativ)': 'Base subject form (ළමයා). Directly maps to German Nominativ (das Kind).',
      'Dvitiya (ද්විතීයා - -va for animates)': 'Accusative marker (ළමයාව / පොත). Directly maps to German Akkusativ (den Jungen / das Buch).',
      'Tritiya (තෘතීයා - -gen / -en)': 'Instrumental marker (පෑනෙන්). Matches German Dativ with preposition "mit".',
      'Chaturthi (චතුර්ථී - -ṭa)': 'Dative/directional marker (පාසලට). Matches German Dativ and prepositions (zu, nach).',
      'Panchami (පඤ්චමී - -gen / -en)': 'Ablative source marker (ගෙදරින්). Matches German Dativ with prepositions "aus" and "von".',
      'Shashthi (ෂෂ්ඨී - -ge / -ē)': 'Genitive possessive marker (ළමයාගේ). Matches German Genitiv (des Kindes).',
      'Saptami (සප්තමී - -ē / -valin)': 'Locative marker (නගරයේ). Matches German Dativ with static preposition "in".',
    },
    this.culturalIslamicLexicon = const {
      'ආයුබෝවන් / සලාම්': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'ස්තූතියි / ශුක්‍රියා': 'Danke / Dankbarkeit (Arabic: شكراً)',
      'කරුණාකර': 'Bitte',
      'පොත / කිතාබ්': 'Buch (Arabic: كتاب)',
      'පාසල / මද්‍රසා': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'ගුරුවරයා / උස්තාද්': 'Lehrer / Meister (Persian: استاد)',
      'දැනුම / ඉල්ම්': 'Wissen / Wissenschaft (Arabic: علم)',
      'යුක්තිය / අදාලත්': 'Gerechtigkeit (Arabic: عدالة)',
      'නමස්කාරය / සලාත්': 'Gebet / Salāt (Persian: نماز)',
      'හලාල්': 'Erlaubt / Halal (Arabic: حلال)',
      'මිතුරා / යහළුවා': 'Freund',
      'වතුර / ජලය': 'Wasser',
      'පාන්': 'Brot / Nahrung',
      'ගෙදර / නිවස': 'Haus / Heim',
      'නගරය': 'Stadt',
      'රෝහල': 'Krankenhaus',
      'ඖෂධ සැල': 'Apotheke',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Mapped to Sinhala "ශ" (e.g., ශාලාව -> Schule, schön).',
      'z /ts/': 'German affricate /ts/; practiced as compound "ත්+ස්" (Zeit -> Tsait).',
      'ch /x/ (ach-Laut)': 'Mapped via velar release contrasting with Sinhala aspirated "ඛ".',
      'ö /ø/ & ü /y/': 'Front rounded vowels mapped through systematic lip rounding from Sinhala /e/ and /i/.',
      'Prenasalized Stop Control': 'Sinhala prenasalized stops (ඟ, ඬ, ඳ, ඹ) are contrasted with German simple voiced stops (g, d, b) to ensure pure acoustic boundaries.',
      'Article System Drill': 'Because Sinhala uses indefiniteness suffix (-ek, -ak) rather than definite articles, learners receive dedicated drills for der, die, das.',
    },
    this.coreA1Vocabulary = const {
      'ආයුබෝවන් / සලාම්': 'Hallo / Guten Tag',
      'සුබ උදෑසනක්': 'Guten Morgen',
      'සුබ දහවලක්': 'Guten Tag',
      'සුබ සන්ධ්‍යාවක්': 'Guten Abend',
      'බොහෝම ස්තූතියි': 'Vielen Dank',
      'කරුණාකර': 'Bitte',
      'ඔව්': 'Ja',
      'නැහැ': 'Nein',
      'මගේ නම ...': 'Mein Name ist ...',
      'ඔබ කොහෙන්ද එන්නේ?': 'Woher kommen Sie?',
      'මම ... සිට පැමිණියෙමි': 'Ich komme aus ...',
      'වතුර': 'Wasser',
      'පාන්': 'Brot',
      'රෝහල': 'Krankenhaus',
      'ඖෂධ සැල': 'Apotheke',
      'දුම්රිය ස්ථානය': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'sinhala': 'ආයුබෝවන්! ඔබට ජර්මන් කතා කළ හැකිද?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'sinhala': 'ඔව්, මම දැන් ජර්මන් භාෂාව ඉගෙන ගන්නවා.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'sinhala': 'කරුණාකර කියන්න, ළඟම ඇති ඖෂධ සැල කොහෙද?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'sinhala': 'ඔබගේ උදව්වට බොහෝම ස්තූතියි!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Sinhala case suffix to its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
