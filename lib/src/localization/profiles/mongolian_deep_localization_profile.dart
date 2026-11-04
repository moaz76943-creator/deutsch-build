import 'package:meta/meta.dart';
import '../matrix/universal_cross_lingual_matrix.dart';

/// Sovereign Deep Localization Profile for Mongolian (Монгол хэл / ᠮᠣᠩᠭᠣᠯ ᠬᠡᠯᠡ).
///
/// Mongolic language spoken by 6M+ people in Mongolia and Inner Mongolia.
/// Characterized by Cyrillic and traditional Bichig scripts, native umlauts
/// (Ө/ө = ö, Ү/ү = ü) matching German directly, strict SOV sentence structure,
/// front/back vowel harmony, and an 8-case agglutinative system.
@immutable
class MongolianDeepLocalizationProfile extends OmnidirectionalLanguageProfile {
  @override
  final String languageName;
  @override
  final String autonym;
  @override
  final String iso6391;
  @override
  final String iso6392or3;
  @override
  final TypologicalClassification typology;
  @override
  final CanonicalWordOrder primaryWordOrder;
  @override
  final GrammaticalAlignment alignment;
  @override
  final bool hasTones;
  @override
  final bool hasGrammaticalGender;

  final String writingDirection;
  final List<String> supportedScripts; // Cyrillic & traditional Bichig
  final bool hasNativeGermanUmlauts; // Ө, Ү = ö, ü!
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const MongolianDeepLocalizationProfile({
    this.languageName = 'Mongolian',
    this.autonym = 'Монгол хэл',
    this.iso6391 = 'mn',
    this.iso6392or3 = 'mon',
    this.typology = TypologicalClassification.agglutinative,
    this.primaryWordOrder = CanonicalWordOrder.sov, // Strict verb-final!
    this.alignment = GrammaticalAlignment.nominativeAccusative,
    this.hasTones = false,
    this.hasGrammaticalGender = false,
    this.writingDirection = 'ltr (Cyrillic) / ttb (Bichig)',
    this.supportedScripts = const ['Cyrillic (Монгол кирилл)', 'Traditional Bichig (ᠮᠣᠩᠭᠣᠯ ᠪᠢᠴᠢᠭ)'],
    this.hasNativeGermanUmlauts = true, // Ө = ö, Ү = ü!
    this.caseSystemAlignment = const {
      '1. Нэрлэх (Nominativ)': 'Unmarked base form (ном). Directly maps to German Nominativ (das Buch).',
      '2. Харьяалах (Genitiv - -ын / -ийн)': 'Possession (багшийн ном). Directly maps to German Genitiv (des Lehrers Buch).',
      '3. Өгөх орших (Dativ/Lokativ - -д / -т)': 'Recipient or location (хотод). Maps to German Dativ & "in/an".',
      '4. Заах (Akkusativ - -ыг / -ийг)': 'Direct object (номыг унших). Maps to German Akkusativ (das Buch lesen).',
      '5. Гарах (Ablativ - -аас / -ээс)': 'Source or separation (гэрээс). Maps to German Dativ with prepositions "aus" and "von".',
      '6. Үйлдэх (Instrumentalis - -аар / -ээр)': 'Instrument or means (машинаар). Maps to German Dativ with preposition "mit".',
      '7. Хамтрах (Komitativ - -тай / -тэй)': 'Accompaniment (найзтай). Maps to German Dativ with preposition "mit".',
      '8. Чиглэх (Direktiv - -руу / -рүү)': 'Direction toward. Maps to German prepositions "nach", "zu".',
    },
    this.culturalIslamicLexicon = const {
      'сайн байна уу / салам': 'Hallo / Begrüßung / Friede (Arabic: سلام)',
      'баярлалаа / их баярлалаа': 'Danke / Vielen Dank',
      'гуйя / тэгээрэй': 'Bitte',
      'ном / судар': 'Buch',
      'сургууль / медресе': 'Schule / Bildungsstätte (Arabic: مدرسة)',
      'багш': 'Lehrer / Dozent',
      'мэдлэг / шинжлэх ухаан': 'Wissen / Wissenschaft',
      'шударга ёс': 'Gerechtigkeit',
      'залбирал / намаз': 'Gebet / Salāt (Persian: نماز)',
      'халал': 'Erlaubt / Halal (Arabic: حلال)',
      'найз / нөхөр': 'Freund',
      'ус': 'Wasser',
      'талх': 'Brot / Nahrung',
      'гэр / байшин': 'Haus / Jurte / Heim',
      'хот': 'Stadt',
      'эмнэлэг': 'Krankenhaus',
      'эмийн сан': 'Apotheke',
      'лалын сүм / сүм': 'Moschee (Arabic: جامع / مسجد)',
    },
    this.germanPhoneticBridges = const {
      'ö /ø/ & ü /y/': '100% Native Identity! Mongolian "Ө / ө" and "Ү / ү" (нөхөр, үнэн) match German "ö" and "ü" (schön, über) with absolute acoustic perfection!',
      'z /ts/': '100% Native Identity! Mongolian "Ц / ц" is strictly /ts/ (e.g. цаг, цэцэг), matching German "z" (Zeit, Zug, Zimmer) flawlessly!',
      'ch /x/ (ach-Laut)': 'Direct 1:1 match to Mongolian "Х / х" (хот, ах, Bach, Nacht).',
      'sch /ʃ/': 'Direct 1:1 match to Mongolian "Ш / ш" (сургууль, Schule, schön).',
      'SOV Verb-Final Advantage': 'Mongolian natively places verbs at the very end of clauses, making German subordinate clause verb-final placement (weil ich Deutsch lerne) second nature!',
    },
    this.coreA1Vocabulary = const {
      'Сайн байна уу': 'Hallo / Guten Tag',
      'Өглөөний мэнд': 'Guten Morgen',
      'Өдрийн мэнд': 'Guten Tag',
      'Оройн мэнд': 'Guten Abend',
      'Маш их баярлалаа': 'Vielen Dank',
      'Гуйя': 'Bitte',
      'Тийм': 'Ja',
      'Үгүй': 'Nein',
      'Миний нэр ...': 'Mein Name ist ...',
      'Та хаанаас ирсэн бэ?': 'Woher kommen Sie?',
      'Би ...-аас/ээс ирсэн': 'Ich komme aus ...',
      'Ус': 'Wasser',
      'Талх': 'Brot',
      'Эмнэлэг': 'Krankenhaus',
      'Эмийн сан': 'Apotheke',
      'Галт тэрэгний буудал': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'mongolian': 'Сайн байна уу! Та германаар ярьдаг уу?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'mongolian': 'Тийм ээ, би одоо герман хэл сурч байна.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'mongolian': 'Уучлаарай, хамгийн ойрхон эмийн сан хаана байдаг вэ?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'mongolian': 'Тусалсанд маш их баярлалаа!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Mongolian case into its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
