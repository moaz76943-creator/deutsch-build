import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Assamese (অসমীয়া / Ôxômiya).
///
/// Eastern Indo-Aryan language spoken by 15M+ people in Assam, Northeast India.
/// Features Eastern Nagari script with distinctive 'ৰ' (/ɹ/ or /r/) and 'ৱ' (/w/),
/// SOV word order, unique sibilant merger into voiceless velar fricative /x/
/// (offering an exact 1:1 native acoustic bridge to German ach-Laut "ch /x/"),
/// extensive numeral classifiers, and an agglutinative case system.
@immutable
class AssameseDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasNativeVelarFricativeX; // Exact match to German ach-Laut ch!
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const AssameseDeepLocalizationProfile({
    this.languageName = 'Assamese',
    this.autonym = 'অসমীয়া',
    this.iso6391 = 'as',
    this.iso6392 = 'asm',
    this.languageFamily = 'Indo-European',
    this.branch = 'Indo-Aryan (Eastern zone / Kamrupic)',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Assamese script (Eastern Nagari)',
    this.specialCharacters = const ['ৰ', 'ৱ', 'ক্ষ', 'ড়', 'ঢ়', 'য়'],
    this.hasNativeVelarFricativeX = true, // Native /x/ phoneme in Assamese!
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'Prathama (প্ৰথমা - subject marker -e / शून्य)': 'Base subject form (ল’ৰাটোৱে / ল’ৰাটো). Directly maps to German Nominativ (der Junge).',
      'Dvitiya (দ্বিতীয়া - -k / -ok - Akkusativ)': 'Accusative marker (কিতাপখনক / ল’ৰাটোক). Directly maps to German Akkusativ (das Buch / den Jungen).',
      'Tritiya (তৃতীয়া - -re / -dwara - Instrumentalis)': 'Instrumental marker (কলমেৰে). Matches German Dativ with preposition "mit".',
      'Chaturthi (চতুৰ্থী - -loi / -k - Dativ)': 'Dative/directional marker (বিদ্যালয়লৈ). Matches German Dativ and prepositions (zu, nach).',
      'Panchami (পঞ্চমী - -r pôra - Ablativ)': 'Ablative source marker (ঘৰৰ পৰা). Matches German Dativ with prepositions "aus" and "von".',
      'Shashthi (ষষ্ঠী - -r - Genitiv)': 'Genitive possessive marker (ল’ৰাটোৰ). Matches German Genitiv (des Jungen).',
      'Saptami (সপ্তমী - -t - Lokativ)': 'Locative marker (চহৰত). Matches German Dativ with static preposition "in".',
    },
    this.culturalIslamicLexicon = const {
      'নমস্কাৰ / ছালাম': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'ধন্যবাদ / শুক্ৰিয়া': 'Danke / Dankbarkeit (Arabic: شكراً)',
      'অনুগ্ৰহ কৰি': 'Bitte',
      'কিতাপ': 'Buch (Arabic: كتاب)',
      'বিদ্যালয় / মাদ্ৰাছা': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'শিক্ষক / ওস্তাদ': 'Lehrer / Meister (Persian: استاد)',
      'জ্ঞান / ইল্ম': 'Wissen / Wissenschaft (Arabic: علم)',
      'ন্যায় / আদালত': 'Gerechtigkeit (Arabic: عدالة)',
      'নমাজ': 'Gebet / Salāt (Persian: نماز)',
      'হালাল': 'Erlaubt / Halal (Arabic: حلال)',
      'বন্ধু / দোস্ত': 'Freund (Persian: دوست)',
      'পানী': 'Wasser',
      'ৰুটী': 'Brot / Nahrung',
      'ঘৰ': 'Haus / Heim',
      'চহৰ': 'Stadt (Persian: شهر)',
      'চিকিৎসালয় / হাস্পাতাল': 'Krankenhaus',
      'ঔষধৰ দোকান': 'Apotheke',
    },
    this.germanPhoneticBridges = const {
      'ch /x/ (ach-Laut)': 'Native 1:1 acoustic match! In Assamese, historic sibilants (শ, ষ, স) are pronounced as voiceless velar fricative /x/ (as in অসম /ôxôm/), matching German "ch" (Bach, Nacht, Buch) effortlessly!',
      'sch /ʃ/': 'Practiced with deliberate palato-alveolar articulation to avoid default Assamese velar fricative /x/.',
      'z /ts/': 'German affricate /ts/; practiced as compound "ত+স" (Zeit -> Tsait).',
      'ö /ø/ & ü /y/': 'Front rounded vowels mapped through systematic lip rounding from Assamese /e/ and /i/.',
      'Classifier System Bridge': 'Because Assamese uses noun classifiers (-to, -khon, -zôn) rather than grammatical articles, learners receive dedicated cognitive anchoring for der, die, das.',
    },
    this.coreA1Vocabulary = const {
      'নমস্কাৰ / ছালাম': 'Hallo / Guten Tag',
      'সুপ্ৰভাত': 'Guten Morgen',
      'শুভ দুপৰীয়া': 'Guten Tag',
      'শুভ সন্ধিয়া': 'Guten Abend',
      'অশেষ ধন্যবাদ': 'Vielen Dank',
      'অনুগ্ৰহ কৰি': 'Bitte',
      'হয়': 'Ja',
      'নহয়': 'Nein',
      'মোৰ নাম ...': 'Mein Name ist ...',
      'আপুনি ক’ৰ পৰা আহিছে?': 'Woher kommen Sie?',
      'মই ...-ৰ পৰা আহিছোঁ': 'Ich komme aus ...',
      'পানী': 'Wasser',
      'ৰুটী': 'Brot',
      'চিকিৎসালয়': 'Krankenhaus',
      'ঔষধৰ দোকান': 'Apotheke',
      'ৰে’ল ষ্টেচন': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'assamese': 'নমস্কাৰ! আপুনি জাৰ্মান ক’ব পাৰেনে?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'assamese': 'হয়, মই এতিয়া জাৰ্মান ভাষা শিকি আছোঁ।',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'assamese': 'অনুগ্ৰহ কৰি কওকচোন, আটাইতকৈ ওচৰৰ ঔষধৰ দোকানখন ক’ত আছে?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'assamese': 'আপোনাৰ সহায়ৰ বাবে অশেষ ধন্যবাদ!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates an Assamese case suffix to its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
