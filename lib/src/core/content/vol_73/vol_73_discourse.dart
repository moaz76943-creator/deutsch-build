// Generated Substantive Discourse Syntax - Tasks 3681-3690
class Vol73DiscourseItem {
  final int taskId;
  final String phrase;
  final String ipa;
  final String arabic;
  final String cefr;
  final String exampleDe;
  final String exampleAr;

  const Vol73DiscourseItem({
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

class Vol73DiscourseRegistry {
  static const List<Vol73DiscourseItem> items = [
    Vol73DiscourseItem(taskId: 3681, phrase: "Rechnung tragen", ipa: "ˈʁɛçnʊŋ ˈtʁaːɡn̩", arabic: "يراعي / يأخذ بعين الحسبان والاعتبار", cefr: "C1", exampleDe: "Die Architektur trägt den strengen Offline-Restriktionen vollkommen Rechnung.", exampleAr: "تراعي البنية الهندسية القيود الصارمة للتشغيل دون اتصال وتأخذها في الحسبان بالكامل."),
    Vol73DiscourseItem(taskId: 3682, phrase: "zur Verantwortung ziehen", ipa: "tsuːɐ̯ fɛɐ̯ˈʔantvɔʁtʊŋ ˈtsiːən", arabic: "يحمل المسؤولية / يستجوب بدقة", cefr: "C1", exampleDe: "Bei Fehlallokationen wird der fehlerhafte Prozess sofort zur Verantwortung gezogen.", exampleAr: "عند حدوث تخصيص خاطئ للذاكرة، تتم مساءلة العملية المعطوبة وإيقافها فوراً."),
    Vol73DiscourseItem(taskId: 3683, phrase: "Abhilfe schaffen", ipa: "ˈapˌhɪlfə ˈʃafn̩", arabic: "يتدارك الأمر / يجد حلاً ناجعاً", cefr: "B2", exampleDe: "Das neue Pufferdesign schafft bei I/O-Engpässen schnell und zuverlässig Abhilfe.", exampleAr: "يوفر تصميم المخزن المؤقت الجديد حلاً ناجعاً وسريعاً لاختناقات الإدخال والإخراج."),
    Vol73DiscourseItem(taskId: 3684, phrase: "Stellung nehmen zu", ipa: "ˈʃtɛlʊŋ ˈneːmən tsuː", arabic: "يبدي رأيه / يوضح موقفه من", cefr: "B2", exampleDe: "Das System nimmt durch präzise Protokolle zu jedem Zustand detailliert Stellung.", exampleAr: "يوضح النظام موقفه وحالته بدقة وتفصيل عبر سجلات حتمية موثوقة."),
    Vol73DiscourseItem(taskId: 3685, phrase: "auf den Grund gehen", ipa: "aʊ̯f deːn ɡʁʊnt ˈɡeːən", arabic: "يتقصى الحقيقة / يبحث في الجذور", cefr: "C1", exampleDe: "Wir müssen der Ursache von Cache-Misses gründlich auf den Grund gehen.", exampleAr: "يتعين علينا أن نتقصى أسباب إخفاق التخزين المؤقت ونبحث في جذورها بدقة."),
    Vol73DiscourseItem(taskId: 3686, phrase: "in den Griff bekommen", ipa: "ɪn deːn ɡʁɪf bəˈkɔmən", arabic: "يسيطر تماماً على / يضبط مسار", cefr: "B2", exampleDe: "Dank komprimierter Indizes haben wir den Speicherverbrauch voll im Griff.", exampleAr: "بفضل الفهارس المضغوطة، أصبح استهلاك الذاكرة تحت السيطرة التامة والضبط الكامل."),
    Vol73DiscourseItem(taskId: 3687, phrase: "zur Last fallen", ipa: "tsuːɐ̯ last ˈfaln̩", arabic: "يشكل عبئاً على / يثقل كاهل", cefr: "C1", exampleDe: "Hintergrundprozesse dürfen dem Akku zu keinem Zeitpunkt zur Last fallen.", exampleAr: "لا يجوز لعمليات الخلفية أن تشكل عبئاً على طاقة البطارية في أي وقت."),
    Vol73DiscourseItem(taskId: 3688, phrase: "freie Hand lassen", ipa: "ˈfʁaɪ̯ə hant ˈlasn̩", arabic: "يطلق له العنان / يمنحه كامل الصلاحية", cefr: "B2", exampleDe: "Wir lassen dem Offline-Scheduler freie Hand bei der Ressourcenverteilung.", exampleAr: "نحن نمنح المجدول المستقل كامل الصلاحية في إدارة وتوزيع الموارد."),
    Vol73DiscourseItem(taskId: 3689, phrase: "in Kauf nehmen", ipa: "ɪn kaʊ̯f ˈneːmən", arabic: "يتقبل العواقب برضا / يتحمل التكلفة", cefr: "B2", exampleDe: "Für garantierte Privatsphäre nehmen wir einen minimalen Mehraufwand gern in Kauf.", exampleAr: "في سبيل ضمان الخصوصية التامة، نتحمل برضا تام التكلفة الحسابية الإضافية الضئيلة."),
    Vol73DiscourseItem(taskId: 3690, phrase: "unter die Lupe nehmen", ipa: "ˈʊntɐ diː ˈluːpə ˈneːmən", arabic: "يفحص بدقة متناهية / يدقق بتمحيص", cefr: "B2", exampleDe: "Wir nehmen jeden einzelnen phonetischen Vektor genauestens unter die Lupe.", exampleAr: "نفحص كل متجه صوتي مفرد بدقة متناهية وتمحيص دقيق."),
  ];

  static Vol73DiscourseItem? byTaskId(int id) {
    try {
      return items.firstWhere((e) => e.taskId == id);
    } catch (_) {
      return null;
    }
  }
}
