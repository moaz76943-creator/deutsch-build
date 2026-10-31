import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Kurdish Sorani (کوردیی ناوەندی / Soranî).
///
/// Northwestern Iranian language spoken by 8M+ people in Iraqi Kurdistan, Iranian
/// Kurdistan, and extensive diaspora across Germany. Features fully vowelled
/// Perso-Arabic orthography (ێ, ۆ, ڵ, ڕ), split ergative pronominal clitics,
/// Izafe construct state, lack of grammatical gender, and SOV clause architecture.
@immutable
class KurdishSoraniDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6393;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasPronominalCliticErgativity;
  final bool hasIzafeConstruct;
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const KurdishSoraniDeepLocalizationProfile({
    this.languageName = 'Kurdish Sorani',
    this.autonym = 'کوردیی ناوەندی',
    this.iso6391 = 'ku',
    this.iso6393 = 'ckb',
    this.languageFamily = 'Indo-European',
    this.branch = 'Northwestern Iranian',
    this.writingDirection = 'rtl',
    this.primaryScript = 'Perso-Arabic (Sorani alphabet)',
    this.specialCharacters = const ['ێ', 'ۆ', 'ڵ', 'ڕ', 'ڤ', 'پ', 'چ', 'ژ', 'گ'],
    this.hasPronominalCliticErgativity = true,
    this.hasIzafeConstruct = true,
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'Subject Base Form (کەرەستەی بکەر)': 'Unmarked subject in present tense (ئەو دەڕوات). Directly maps to German Nominativ (er geht).',
      'Pronominal Clitic Direct Object (-م/-ت/-ی)': 'Enclitic pronoun marking past transitive agent or present object. Maps to German Akkusativ/Dativ.',
      'Preposition "لەگەڵ" (lagal - Instrumentalis)': 'Accompaniment. Directly maps to German Dativ with preposition "mit".',
      'Preposition "بۆ" (bo - Dativ / Allativ)': 'Direction or beneficiary. Directly maps to German Dativ and preposition "zu/für".',
      'Preposition "لە" (la - Ablativ)': 'Origin and separation. Directly maps to German Dativ with prepositions "aus" and "von".',
      'Circumposition "لە ... دا" (la ... da - Lokativ)': 'Location inside. Directly maps to German Dativ with static preposition "in".',
      'Izafe Construct (-î / -ی - Genitiv)': 'Connective vowel marking possession (کتێبی مامۆستا). Directly maps to German Genitiv (das Buch des Lehrers).',
    },
    this.culturalIslamicLexicon = const {
      'سڵاو / سڵاوی خواتان لێ بێت': 'Friede / Begrüßung (Arabic: سلام)',
      'سوپاس / دەستت خۆش بێت': 'Danke / Dankbarkeit',
      'تکایە / بێزەحمەت': 'Bitte',
      'کتێب': 'Buch (Arabic: كتاب)',
      'قوتابخانە / مەدرەسە': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'مامۆستا': 'Lehrer / Meister (Persian: استاد)',
      'زانست / زانیاری': 'Wissen / Wissenschaft',
      'دادپەروەری / عەدالەت': 'Gerechtigkeit (Arabic: عدالة)',
      'نوێژ / سەڵات': 'Gebet / Salāt (Persian/Arabic: نماز / صلاة)',
      'حەڵاڵ': 'Erlaubt / Halal (Arabic: حلال)',
      'هاوڕێ / دۆست': 'Freund (Persian: دوست)',
      'ئاو': 'Wasser',
      'نان': 'Brot / Nahrung',
      'ماڵ': 'Haus / Heim',
      'شار': 'Stadt (Persian: شهر)',
      'نەخۆشخانە': 'Krankenhaus',
      'دەرمانخانە': 'Apotheke (Persian: درمان خانه)',
      'مزگەوت': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Sorani "ش" (شەو, شار, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Sorani "چ" (چاو, Deutschland).',
      'ch /x/ (ach-Laut)': 'Direct 1:1 match to Sorani "خ" (خۆش, خانوو, Bach, Nacht).',
      'z /ts/': 'German affricate /ts/; practiced as compound "ت+س" (Zeit -> Tsait).',
      'ö /ø/ & ü /y/': 'Front rounded vowels mapped through systematic lip rounding from Sorani "ۆ" /o/ and "وو" /u/.',
      'Article System Drill': 'Because Sorani uses definiteness suffix (-ەکە / -aka) rather than preposed articles, learners receive targeted training for der, die, das.',
    },
    this.coreA1Vocabulary = const {
      'سڵاو': 'Hallo / Guten Tag',
      'بەیانیت باش': 'Guten Morgen',
      'ڕۆژباش': 'Guten Tag',
      'ئێوارە باش': 'Guten Abend',
      'زۆر سوپاس': 'Vielen Dank',
      'تکایە': 'Bitte',
      'بەڵێ': 'Ja',
      'نەخێر': 'Nein',
      'ناوی من ...ە': 'Mein Name ist ...',
      'خەڵکی کوێیت؟': 'Woher kommen Sie?',
      'من خەڵکی ...م': 'Ich komme aus ...',
      'ئاو': 'Wasser',
      'نان': 'Brot',
      'نەخۆشخانە': 'Krankenhaus',
      'دەرمانخانە': 'Apotheke',
      'وێستگەی شەمەندەفەر': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'sorani': 'سڵاو! ئایا دەتوانیت بە ئەڵمانی قسە بکەیت؟',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'sorani': 'بەڵێ، من ئێستا زمانی ئەڵمانی فێر دەبم.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'sorani': 'تکایە، نزیکترین دەرمانخانە لە کوێیە؟',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'sorani': 'زۆر سوپاس بۆ هاوکارییەکەت!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Sorani case/preposition structure into its German equivalent.
  String? getGermanCaseBridge(String relationName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(relationName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
