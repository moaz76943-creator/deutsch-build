// Generated Substantive Discourse Syntax - Tasks 3741-3750
class Vol75DiscourseItem {
  final int taskId;
  final String phrase;
  final String ipa;
  final String arabic;
  final String cefr;
  final String exampleDe;
  final String exampleAr;

  const Vol75DiscourseItem({
    required this.taskId,
    required this.phrase,
    required this.ipa,
    required this.arabic,
    required this.cefr,
    required this.exampleDe,
    required this.exampleAr,
  });

  bool isValid() => phrase.isNotEmpty && ipa.isNotEmpty && arabic.isNotEmpty;
}

class Vol75DiscourseRegistry {
  static const List<Vol75DiscourseItem> items = [
    Vol75DiscourseItem(taskId: 3741, phrase: "in Erfahrung bringen", ipa: "ɪn ɛɐ̯ˈfaːʁʊŋ ˈbʁɪŋən", arabic: "يستعلم عن / يتقصى المعرفة بدقة", cefr: "B2", exampleDe: "Wir müssen die genaue Hardware-Spezifikation vor der Allokation in Erfahrung bringen.", exampleAr: "يجب أن نتقصى مواصفات العتاد بدقة قبل الشروع في تخصيص الذاكرة."),
    Vol75DiscourseItem(taskId: 3742, phrase: "zur Disposition stehen", ipa: "tsuːɐ̯ dɪspɔziˈtsi̯oːn ˈʃteːən", arabic: "يكون مطروحاً للنقاش والتعديل", cefr: "C1", exampleDe: "Die kompromisslose Privatsphäre steht zu keinem Zeitpunkt zur Disposition.", exampleAr: "الخصوصية التامة ليست مطروحة للنقاش أو المساومة في أي وقت."),
    Vol75DiscourseItem(taskId: 3743, phrase: "in die Tat umsetzen", ipa: "ɪn diː taːt ˈʊmˌzɛtsn̩", arabic: "يضع موضع التنفيذ الفعلي / يحول لواقع", cefr: "B2", exampleDe: "Das Team setzt die neuen Offline-Optimierungen unmittelbar in die Tat um.", exampleAr: "يحول الفريق الهندسي تحسينات العمل دون اتصال إلى واقع ملموس فوراً."),
    Vol75DiscourseItem(taskId: 3744, phrase: "einer Sache gewachsen sein", ipa: "ˈaɪ̯nɐ ˈzaxə ɡəˈvaksn̩ zaɪ̯n", arabic: "يكون على قدر التحدي / مؤهلاً تماماً", cefr: "B2", exampleDe: "Die lokale Datenbank ist auch extremen Schreiblasten vollauf gewachsen.", exampleAr: "قاعدة البيانات المحلية على قدر التحدي ومؤهلة تماماً لتحمل ضغط الكتابة العالي."),
    Vol75DiscourseItem(taskId: 3745, phrase: "in Erstaunen versetzen", ipa: "ɪn ɛɐ̯ˈʃtaʊ̯nən fɛɐ̯ˈzɛtsn̩", arabic: "يثير الدهشة والإعجاب بكفاءته", cefr: "B2", exampleDe: "Die blitzschnelle phonetische Suche versetzt selbst erfahrene Entwickler in Erstaunen.", exampleAr: "يثير البحث الصوتي فائق السرعة دهشة وإعجاب المطورين المتمرسين."),
    Vol75DiscourseItem(taskId: 3746, phrase: "zur Kenntnis nehmen", ipa: "tsuːɐ̯ ˈkɛntnɪs ˈneːmən", arabic: "يحيط علماً بـ / يدرك رسمياً", cefr: "B2", exampleDe: "Der Watchdog nimmt jede Systemwarnung ohne Verzögerung zur Kenntnis.", exampleAr: "يحيط المراقب الآلي علماً بكل تحذير صادر عن النظام دون أدنى تأخير."),
    Vol75DiscourseItem(taskId: 3747, phrase: "auf die Schliche kommen", ipa: "aʊ̯f diː ˈʃlɪçə ˈkɔmən", arabic: "يكشف الخلل المستتر / يتعقب المشكلة", cefr: "C1", exampleDe: "Durch präzises Tracing kommen wir subtilen Speicherlecks schnell auf die Schliche.", exampleAr: "من خلال التتبع الدقيق، نكشف مواضع تسريب الذاكرة الخفية ونتعقبها بسرعة."),
    Vol75DiscourseItem(taskId: 3748, phrase: "in Einklang stehen mit", ipa: "ɪn ˈaɪ̯nklaŋ ˈʃteːən mɪt", arabic: "يتناغم تماماً مع / يتوافق مع", cefr: "C1", exampleDe: "Das Datenformat steht in vollem Einklang mit offenen Standards.", exampleAr: "تتناغم صيغة البيانات تماماً وتتوافق مع المعايير البرمجية المفتوحة."),
    Vol75DiscourseItem(taskId: 3749, phrase: "zu kurz kommen", ipa: "tsuː kʊʁts ˈkɔmən", arabic: "يُغبن حقه / يُهمل جانب منه", cefr: "B2", exampleDe: "Bei maximaler Geschwindigkeit darf die semantische Präzision niemals zu kurz kommen.", exampleAr: "مع تحقيق أقصى سرعة ممكنة، لا يجوز إغفال أو إهمال الدقة الدلالية."),
    Vol75DiscourseItem(taskId: 3750, phrase: "außer Betracht bleiben", ipa: "ˈaʊ̯sɐ bəˈtʁaxt ˈblaɪ̯bn̩", arabic: "يبقى مستبعداً من الاعتبار / لا يؤخذ في الحسبان", cefr: "C1", exampleDe: "Externe Cloud-Dienste müssen beim Systementwurf völlig außer Betracht bleiben.", exampleAr: "يجب استبعاد الخدمات السحابية الخارجية تماماً من الحسبان عند تصميم النظام."),
  ];

  static Vol75DiscourseItem? byTaskId(int id) {
    try {
      return items.firstWhere((e) => e.taskId == id);
    } catch (_) {
      return null;
    }
  }
}
