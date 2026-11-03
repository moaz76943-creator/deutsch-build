import 'package:meta/meta.dart';

/// Sovereign Deep Localization Profile for Tajik (Тоҷикӣ / Tojikī).
///
/// Southwestern Iranian language spoken by 10M+ people in Tajikistan, Uzbekistan,
/// and Russia. Written in Cyrillic with distinctive Tajik graphemes (Ғ, Ӣ, Қ, Ӯ, Ҳ, Ҷ),
/// featuring SOV syntax, Izafe construct state, direct accusative marker -ро (-ro),
/// and prepositional case frames directly mapping to German Dativ prepositions.
@immutable
class TajikDeepLocalizationProfile {
  final String languageName;
  final String autonym;
  final String iso6391;
  final String iso6392;
  final String languageFamily;
  final String branch;
  final String writingDirection;
  final String primaryScript;
  final List<String> specialCharacters;
  final bool hasIzafeConstruct;
  final String wordOrder;
  final Map<String, String> caseSystemAlignment;
  final Map<String, String> culturalIslamicLexicon;
  final Map<String, String> germanPhoneticBridges;
  final Map<String, String> coreA1Vocabulary;
  final List<Map<String, String>> practicalDialoguePhrases;

  const TajikDeepLocalizationProfile({
    this.languageName = 'Tajik',
    this.autonym = 'Тоҷикӣ',
    this.iso6391 = 'tg',
    this.iso6392 = 'tgk',
    this.languageFamily = 'Indo-European',
    this.branch = 'Southwestern Iranian',
    this.writingDirection = 'ltr',
    this.primaryScript = 'Cyrillic (Tajik alphabet)',
    this.specialCharacters = const ['Ғ', 'ғ', 'Ӣ', 'ӣ', 'Қ', 'қ', 'Ӯ', 'ӯ', 'Ҳ', 'ҳ', 'Ҷ', 'ҷ'],
    this.hasIzafeConstruct = true,
    this.wordOrder = 'SOV',
    this.caseSystemAlignment = const {
      'Subject Base Form (Мубтадо - Nominativ)': 'Unmarked subject form (писар). Directly maps to German Nominativ (der Junge).',
      'Definite Direct Object (-ро / -ro - Akkusativ)': 'Definite object suffix (китобро). Directly maps to German Akkusativ (das Buch / den Mann).',
      'Preposition "бо" (bo - Instrumentalis)': 'Accompaniment or instrument. Matches German Dativ with preposition "mit".',
      'Preposition "ба" (ba - Dativ / Allativ)': 'Direction or recipient. Matches German Dativ and prepositions "zu" and "nach".',
      'Preposition "аз" (az - Ablativ)': 'Source or separation. Matches German Dativ with prepositions "aus" and "von".',
      'Preposition "дар" (dar - Lokativ)': 'Location inside. Matches German Dativ with static preposition "in".',
      'Izafe Construct (-и / -i - Genitiv)': 'Connective vowel marking possession (хонаи падар). Matches German Genitiv (das Haus des Vaters).',
    },
    this.culturalIslamicLexicon = const {
      'салом / ассалому алайкум': 'Friede / Begrüßung (Arabic: سلام)',
      'ташаккур / раҳмат': 'Danke / Dankbarkeit (Arabic: تشكر / رحمة)',
      'лутфан / марҳамат': 'Bitte (Arabic: لطفاً / مرحمة)',
      'китоб': 'Buch (Arabic: كتاب)',
      'мактаб': 'Schule (Arabic: مكتب)',
      'муаллим': 'Lehrer (Arabic: معلم)',
      'илм': 'Wissenschaft / Wissen (Arabic: علم)',
      'адолат': 'Gerechtigkeit (Arabic: عدالة)',
      'намоз': 'Gebet / Salāt (Persian/Arabic: نماز / صلاة)',
      'ҳалол': 'Erlaubt / Halal (Arabic: حلال)',
      'дӯст': 'Freund (Persian: دوست)',
      'об': 'Wasser',
      'нон': 'Brot / Nahrung',
      'хона': 'Haus / Heim',
      'шаҳр': 'Stadt (Persian: شهر)',
      'беморхона': 'Krankenhaus (Persian: بیمارخانه)',
      'дорухона': 'Apotheke (Persian: داروخانه)',
    },
    this.germanPhoneticBridges = const {
      'sch /ʃ/': 'Direct 1:1 match to Tajik "Ш / ш" (шаҳр, Schule, schön).',
      'ch /x/ (ach-Laut)': 'Direct match to Tajik "Х / х" (бахт, Bach, Nacht).',
      'h /h/': 'Direct match to Tajik glottal "Ҳ / ҳ" (ҳаёт, haben, heute).',
      'z /ts/': 'Tajik "З / з" is voiced /z/; German "z" is an affricate /ts/, practiced as "т+с" compound.',
      'ö /ø/ & ü /y/': 'Tajik "Ӯ / ӯ" serves as acoustic baseline for front-rounded vowels with active lip protrusion.',
      'Article System Drill': 'Because Tajik lacks grammatical gender and articles, learners receive dedicated cognitive anchoring for der, die, das.',
    },
    this.coreA1Vocabulary = const {
      'Салом / Ассалому алайкум': 'Hallo / Guten Tag',
      'Субҳ ба хайр': 'Guten Morgen',
      'Рӯз ба хайр': 'Guten Tag',
      'Шом ба хайр': 'Guten Abend',
      'Ташаккури зиёд': 'Vielen Dank',
      'Лутфан': 'Bitte',
      'Ҳа': 'Ja',
      'Не': 'Nein',
      'Номи ман ... аст': 'Mein Name ist ...',
      'Шумо аз куҷоед?': 'Woher kommen Sie?',
      'Ман аз ... ҳастам': 'Ich komme aus ...',
      'Об': 'Wasser',
      'Нон': 'Brot',
      'Беморхона': 'Krankenhaus',
      'Дорухона': 'Apotheke',
      'Истгоҳи роҳи оҳан': 'Bahnhof',
    },
    this.practicalDialoguePhrases = const [
      {
        'tajik': 'Салом! Оё шумо ба забони олмонӣ гап мезанед?',
        'german': 'Guten Tag! Sprechen Sie Deutsch?',
        'arabic': 'مرحباً! هل تتحدث الألمانية؟',
      },
      {
        'tajik': 'Ҳа, ман ҳозир забони олмониро меомӯзам.',
        'german': 'Ja, ich lerne gerade die deutsche Sprache.',
        'arabic': 'نعم، أنا أتعلم اللغة الألمانية حالياً.',
      },
      {
        'tajik': 'Лутфан бигӯед, наздиктарин дорухона дар куҷост?',
        'german': 'Wo ist bitte die nächste Apotheke?',
        'arabic': 'من فضلك، أين تقع أقرب صيدلية؟',
      },
      {
        'tajik': 'Барои кӯмакатон ташаккури зиёд!',
        'german': 'Vielen Dank für Ihre Hilfe!',
        'arabic': 'شكراً جزيلاً على مساعدتك!',
      },
    ],
  });

  /// Translates a Tajik case/preposition structure into its German equivalent.
  String? getGermanCaseBridge(String relationName) {
    for (final entry in caseSystemAlignment.entries) {
      if (entry.key.toLowerCase().contains(relationName.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }
}
