import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Marathi (मराठी).
///
/// Major Indo-Aryan language spoken by 83M+ people in Maharashtra.
/// Retains archaic 3-gender system (पुल्लिंग, स्त्रीलिंग, नपुंसकलिंग) and native
/// alveolar affricates (/ts/ allophone of 'च'), providing an immediate native
/// phonetic match for German "z" (/ts/) and structural bridge to "der, die, das"!
@immutable
class MarathiDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final bool hasThreeGenders;
  final bool hasNativeAffricateTS; // Native /ts/ sound in Marathi!
  final String wordOrder;
  final Map<String, String> genderEquivalenceMap;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const MarathiDeepLocalizationProfile({
    this.languageName = 'Marathi',
    this.autonym = 'मराठी',
    this.iso6391 = 'mr',
    this.iso6392 = 'mar',
    this.languageFamily = 'Indo-European',
    this.branch = 'Indo-Aryan (Southern zone)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Balbodh (Devanagari)',
    this.hasThreeGenders = true,
    this.hasNativeAffricateTS = true,
    this.wordOrder = 'SOV',
    this.genderEquivalenceMap = const {
      'Pullinga (पुल्लिंग)': 'German Maskulinum (der) - e.g., मुलगा (der Junge), सूर्य (die Sonne/masc).',
      'Strilinga (स्त्रीलिंग)': 'German Femininum (die) - e.g., मुलगी (das Mädchen/fem), रात्र (die Nacht).',
      'Napunsakalinga (नपुंसकलिंग)': 'German Neutrum (das) - e.g., मूल (das Kind), पुस्तक (das Buch).',
    },
    this.caseSystemAlignment = const {
      'Prathama (प्रथमा - Nominativ)': 'Base subject form (मुलगा वाचतो). Direct match to German Nominativ (der Junge liest).',
      'Dvitiya / Chaturthi (-ला / -la - Akkusativ/Dativ)': 'Object suffix with base stem change (Samanya-rupa: मुलाला). Matches German Akkusativ & Dativ.',
      'Tritiya (-ने / -ne - Instrumentalis)': 'Agent or instrument (मुलाने). Matches German Dativ with preposition "mit".',
      'Panchami (-हून/-तून / -hun/-tun - Ablativ)': 'Origin or separation (घरातून). Matches German Dativ with prepositions "aus" and "von".',
      'Shashthi (-चा/-ची/-चे / -cha/-chi/-che - Genitiv)': 'Possessive marker with gender concord. Matches German Genitiv (des Buches).',
      'Saptami (-त / -t - Lokativ)': 'Location inside (शहरात). Matches German Dativ with preposition "in" (in der Stadt).',
    },
    this.culturalIslamicLexicon = const {
      'सलाम': 'Friede / Begrüßung (Arabic: سلام)',
      'धन्यवाद / शुक्रिया': 'Danke / Dankbarkeit (Arabic: شكراً)',
      'कृपया / मेहरबानी करून': 'Bitte / Freundlichkeit (Arabic/Persian: مهرباني)',
      'पुस्तक / किताब': 'Buch (Arabic: كتاب)',
      'शाळा / मकतब': 'Schule (Arabic: مكتب)',
      'शिक्षक / उस्ताद': 'Lehrer / Meister (Persian: استاد)',
      'ज्ञान / इल्म': 'Wissen / Wissenschaft (Arabic: علم)',
      'न्याय / अदालत': 'Gerechtigkeit (Arabic: عدالة)',
      'नमाज': 'Gebet / Salāt (Persian: نماز)',
      'हलाल': 'Erlaubt / Halal (Arabic: حلال)',
      'मित्र / दोस्त': 'Freund (Persian: دوست)',
      'पाणी': 'Wasser',
      'भाकरी / पोळी': 'Brot / Nahrung',
      'घर': 'Haus / Heim',
      'शहर': 'Stadt (Persian: शहर)',
      'रुग्णालय / दवाखाना': 'Krankenhaus (Persian: دواخانه)',
      'औषधांचे दुकान': 'Apotheke',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': 'Native 1:1 acoustic match! Marathi "च" before back vowels is naturally pronounced as dental affricate /ts/ (as in चमचा /tsamtsa/), matching German "z" (Zeit, Zug) effortlessly!',
      'sch /ʃ/': 'Direct 1:1 match to Marathi "श" (e.g., शाळा, शहर, Schule, schön).',
      'ch /x/ (ach-Laut)': 'Mapped to Marathi aspirated "ख" with softened fricative release (Nacht, Buch).',
      'ö /ø/ & ü /y/': 'Front rounded vowels mapped through systematic lip-rounding drills from Marathi /e/ and /i/.',
      'Samanya-rupa Bridge': 'Marathi stem-modification before case markers directly prepares learners for German definite article and adjective declensions.',
    },
    this.coreA1Vocabulary = const {
      'नमस्कार / सलाम': 'Hallo / Guten Tag',
      'शुभ सकाळ': 'Guten Morgen',
      'शुभ दुपार': 'Guten Tag',
      'शुभ संध्याकाळ': 'Guten Abend',
      'खूप खूप धन्यवाद': 'Vielen Dank',
      'कृपया': 'Bitte',
      'होय': 'Ja',
      'नाही': 'Nein',
      'माझे नाव ... आहे': 'Mein Name ist ...',
      'तुम्ही कुठून आहात?': 'Woher kommen Sie?',
      'मी ... हून आलो आहे': 'Ich komme aus ...',
      'पाणी': 'Wasser',
      'भाकरी': 'Brot',
      'रुग्णालय': 'Krankenhaus',
      'औषधांचे दुकान': 'Apotheke',
      'रेल्वे स्टेशन': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'marathi': 'नमस्कार! आपण जर्मन बोलता का?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'marathi': 'होय, मी सध्या जर्मन भाषा शिकत आहे.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'marathi': 'कृपया सांगा, सर्वात जवळचे औषधांचे दुकान कुठे आहे?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'marathi': 'आपल्या मदतीबद्दल खूप खूप धन्यवाद!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Confirms that Marathi possesses native affricate /ts/ pronunciation.
  bool hasNativeGermanZSound() {
    return hasNativeAffricateTS;
  }
}
