import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Avar (Магӏарул мацӏ / Авар мацӏ).
///
/// Northeast Caucasian (Avar-Andic) language spoken by 1M+ people; historical
/// lingua franca of Dagestan and the mountainous North Caucasus. Characterized by
/// ergative alignment, 3 noun classes, a 20-case spatial localization matrix
/// (5 spatial positions x 4 directional forms), and exact 1:1 match of letter 'Ц/ц'
/// to German 'Z/z' (/ts/).
@immutable
class AvarDeepLocalizationProfile {
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
  final bool hasSpatialCaseMatrix; // 20 spatial cases!
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List> practicalDialoguePhrases;

  const AvarDeepLocalizationProfile({
    this.languageName = 'Avar',
    this.autonym = 'Магӏарул мацӏ',
    this.iso6391 = 'av',
    this.iso6392 = 'ava',
    this.languageFamily = 'Northeast Caucasian',
    this.branch = 'Avar-Andic',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Cyrillic (with palochka ӏ) / historic Ajami',
    this.specialCharacters = const ['ӏ', 'гъ', 'гь', 'къ', 'кь', 'лъ', 'тӏ', 'хъ', 'хь', 'хӏ', 'цӏ', 'чӏ'],
    this.hasErgativeAlignment = true,
    this.hasSpatialCaseMatrix = true, // 5 local orientations x 4 directional forms
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      '1. Тӏоцебесеб падеж (Absolutive / Nominativ)': 'Direct subject of intransitive or patient of transitive. Maps to German Nominativ/Akkusativ.',
      '2. Хаслъул падеж (Genitiv - -л / -сул / -лъул)': 'Possession (васасул тӏехь). Directly maps to German Genitiv (des Jungen Buch).',
      '3. Кьовул падеж (Dativ - -е)': 'Recipient or beneficiary (васасе). Directly maps to German Dativ (dem Jungen).',
      '4. Актив падеж (Ergativ - -с / -ца)': 'Agent of transitive verb (васас тӏехь цӏалана). Maps to German transitive subject.',
      '5. Локатив I (Inessiv - -лъ - жаниб)': 'Inside static location. Directly maps to German Dativ with preposition "in".',
      '6. Локатив II (Adessiv - -хъ - аскӏоб)': 'At/by static location. Directly maps to German Dativ with preposition "bei" and "an".',
      '7. Аблатив (Motus a loco - -са / -сан)': 'Movement out of/away from. Directly maps to German Dativ with prepositions "aus" and "von".',
      '8. Аллатив (Motus ad locum - -де)': 'Movement toward. Directly maps to German Dativ with prepositions "zu" and "nach".',
    },
    this.culturalIslamicLexicon = const {
      'салам / ворчӏами': 'Friede / Begrüßung (Arabic: سلام)',
      'баркала': 'Danke (Arabic: بارك الله - Baraka Allah)',
      'гьари': 'Bitte',
      'тӏехь / китаб': 'Buch (Arabic: كتاب)',
      'школа / мадраса': 'Schule / Medrese (Arabic: مدرسة)',
      'мугӏалим / магӏалим': 'Lehrer / Dozent (Arabic: معلم)',
      'гӏелму': 'Wissen / Wissenschaft (Arabic: علم)',
      'гӏадалат': 'Gerechtigkeit (Arabic: عدالة)',
      'как / намаз': 'Gebet / Salāt (Persian: نماز)',
      'хӏалал': 'Erlaubt / Halal (Arabic: حلال)',
      'гьудул': 'Freund',
      'лъим': 'Wasser',
      'чед': 'Brot / Nahrung',
      'рукъ': 'Haus / Heim',
      'шагьар': 'Stadt (Persian: شهر)',
      'азархана': 'Krankenhaus (Persian: آزارخانه)',
      'даррухана': 'Apotheke (Persian: داروخانه)',
      'мажгит': 'Moschee (Arabic: مسجد)',
    },
    this.germanPhoneticBridges = const {
      'z /ts/': '100% Native Identity! Avar "Ц / ц" is strictly /ts/ (e.g. ца, цо), matching German "z" (Zeit, Zug, Zimmer) flawlessly!',
      'sch /ʃ/': 'Direct 1:1 match to Avar "Ш / ш" (шагьар, Schule, schön).',
      'ch /x/ (ach-Laut)': 'Direct match to Avar "Х / х" (хабар, Bach, Nacht).',
      'tsch /tʃ/': 'Direct 1:1 match to Avar "Ч / ч" (чай, чед, Deutschland).',
      'Spatial Case Matrix Advantage': 'Avar\'s multi-dimensional 20-case spatial framework makes German two-way prepositions (in, an, auf, unter, vor with Dativ/Akkusativ) intuitively clear and effortlessly mastered.',
    },
    this.coreA1Vocabulary = const {
      'Салам / Ворчӏами': 'Hallo / Guten Tag',
      'Радал дика': 'Guten Morgen',
      'Къо дика': 'Guten Tag',
      'Сордо дика': 'Guten Abend',
      'Кӏудияб баркала': 'Vielen Dank',
      'Гьари': 'Bitte',
      'У': 'Ja',
      'Гуро': 'Nein',
      'Дир цӏар ... буго': 'Mein Name ist ...',
      'Мун киса кколев/кколей?': 'Woher kommen Sie?',
      'Дун ...-са вуго/йиго': 'Ich komme aus ...',
      'Лъим': 'Wasser',
      'Чед': 'Brot',
      'Азархана': 'Krankenhaus',
      'Даррухана': 'Apotheke',
      'Рекӏел некьел вокзал': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'avar': 'Салам! Дуда немец мацӏ лъалищ?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'avar': 'У, дица гьанже немец мацӏ лъазабулеб буго.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'avar': 'Гьари, бице, бищун аскӏоб бугеб даррухана киб бугеб?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'avar': 'Кумекалъе кӏудияб баркала!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates an Avar case into its German prepositional/case equivalent.
  String? getGermanCaseBridge(String caseName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(caseName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
