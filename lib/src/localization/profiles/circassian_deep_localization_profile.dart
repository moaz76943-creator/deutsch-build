import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Circassian / Adyghe (Адыгэбзэ).
///
/// Northwest Caucasian language spoken by 1.6M+ people in the Caucasus and historical
/// diaspora communities across Jordan (Amman, Wadi al-Seer, Naour), Turkey, Syria, and Germany.
/// Characterized by polysynthetic verb morphology, ergative-absolutive case alignment,
/// rich consonant inventory (50+ consonants), and exact 1:1 match of letter 'Ц/ц' to German 'Z/z' (/ts/).
@immutable
class CircassianDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasErgativeAlignment;
  final bool isPolysynthetic;
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const CircassianDeepLocalizationProfile({
    this.languageName = 'Circassian',
    this.autonym = 'Адыгэбзэ',
    this.iso6391 = 'ady',
    this.iso6392 = 'ady',
    this.languageFamily = 'Northwest Caucasian',
    this.branch = 'Circassian',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Cyrillic (with palochka Ӏ)',
    this.specialCharacters = const ['Ӏ', 'ӏ', 'гъ', 'къ', 'лъ', 'лӏ', 'пӏ', 'тӏ', 'фӏ', 'хь', 'цӏ', 'чӏ', 'шӏ'],
    this.hasErgativeAlignment = true,
    this.isPolysynthetic = true,
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      '1. Именительнэ / Абсолютив (-р / -r)': 'Subject of intransitive or patient of transitive. Directly maps to German Nominativ/Akkusativ.',
      '2. Эргатив / Косвеннэ (-м / -m)': 'Agent of transitive verb, indirect object, possessor. Directly maps to German transitive subject, Dativ & Genitiv.',
      '3. Творительнэ (-кӏэ / -k\'e - Instrumentalis)': 'Instrument or direction. Directly maps to German Dativ with preposition "mit".',
      '4. Превратительнэ (-у / -w - Translativ)': 'State or transformation. Maps to German preposition "als" or "zu" (als Lehrer / zum Lehrer).',
    },
    this.culturalIslamicLexicon = const {
      'шъуфэсакъ / салам': 'Willkommen / Friede / Begrüßung (Arabic: سلام)',
      'тхьауегъэпсэу / баркалла': 'Danke / Gott schenke dir langes Leben',
      'тхьашӏукӏэ': 'Bitte',
      'тхылъ': 'Buch',
      'еджапӏэ / хьужар': 'Schule / Bildungsstätte (Arabic: حجرة / مدرسة)',
      'егъадж': 'Lehrer / Dozent',
      'шӏэныгъэ': 'Wissen / Wissenschaft',
      'шъыпкъагъэ / адаләт': 'Gerechtigkeit / Wahrheit (Arabic: عدالة)',
      'тхьэлъэӏу / нэмэз': 'Gebet / Salāt (Persian: نماز)',
      'хьэлял': 'Erlaubt / Halal (Arabic: حلال)',
      'ныбджэгъу': 'Freund',
      'псы': 'Wasser',
      'хьалыгъу': 'Brot / Nahrung',
      'унэ': 'Haus / Heim',
      'къалэ': 'Stadt (Turkish/Arabic: قلعة)',
      'сымаджэщ': 'Krankenhaus',
      'дэрмэнщэ': 'Apotheke (Persian: درمان)',
      'мэщыт': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Circassian "Ц / ц" is strictly /ts/ (e.g. цэй, цы), matching German "z" (Zeit, Zug, Zimmer) with zero distortion!',
      'sch /ʃ/': 'Direct 1:1 match to Circassian "Ш / ш" (шапсыгъ, Schule, schön).',
      'tsch /tʃ/': 'Direct 1:1 match to Circassian "Ч / ч" (чай, чехка, Deutschland).',
      'ch /x/ (ach-Laut)': 'Direct match to Circassian "Х / х" (хьалыгъу, хъер, Bach, Nacht).',
      'Consonant Acuity Advantage': 'Circassian learners operate with 50+ distinctive consonants, making German consonant onsets and codas (pflücken, Herbst, Angst) instantly transparent and easy to articulate.',
    },
    this.coreA1Vocabulary = const {
      'Шъуфэсакъ / Салам': 'Hallo / Guten Tag',
      'Пчэдыжьышӏу': 'Guten Morgen',
      'Мафышӏу': 'Guten Tag',
      'Пчыхьэшӏу': 'Guten Abend',
      'Тхьауегъэпсэу': 'Vielen Dank',
      'Тхьашӏукӏэ': 'Bitte',
      'Ары': 'Ja',
      'Хьау': 'Nein',
      'Сэ сцӏэр ...': 'Mein Name ist ...',
      'Тыдэ укъикӏыгъ?': 'Woher kommen Sie?',
      'Сэ ... сыкъикӏыгъ': 'Ich komme aus ...',
      'Псы': 'Wasser',
      'Хьалыгъу': 'Brot',
      'Сымаджэщ': 'Krankenhaus',
      'Дэрмэнщэ': 'Apotheke',
      'Гъогу вокзал': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'circassian': 'Шъуфэсакъ! Немыцэбзэкӏэ угущыӏэшъущта?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'circassian': 'Ары, сэ джы немыцэбзэр зэсэгъашӏэ.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'circassian': 'Тхьашӏукӏэ, аптэкэр тыдэ щыӏа?',
        'german': 'Wo ist bitte die Apotheke?',
        'arabic': 'من فضلك، أين تقع الصيدلية؟',
      },
      {
        'circassian': 'Ӏэпыӏэгъу пшӏыгъэмкӏэ тхьауегъэпсэу!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Circassian case into its German equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
