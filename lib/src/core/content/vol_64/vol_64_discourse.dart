// Generated Substantive Discourse Syntax - Tasks 3411-3420
class Vol64DiscourseItem {
  final int taskId;
  final String phrase;
  final String ipa;
  final String arabic;
  final String cefr;
  final String exampleDe;
  final String exampleAr;

  const Vol64DiscourseItem({
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

class Vol64DiscourseRegistry {
  static const List<Vol64DiscourseItem> items = [
    Vol64DiscourseItem(taskId: 3411, phrase: "wenngleich", ipa: "vɛnˈɡlaɪ̯ç", arabic: "وإن كان / مع أن", cefr: "C1", exampleDe: "Wenngleich die Hürden hoch sind, setzen wir das Vorhaben fort.", exampleAr: "على الرغم من صعوبة العوائق، فإننا ماضون في تنفيذ المشروع."),
    Vol64DiscourseItem(taskId: 3412, phrase: "ungeachtet dessen", ipa: "ˈʊnɡəˌʔaxtət ˈdɛsn̩", arabic: "بصرف النظر عن ذلك / على الرغم من ذلك", cefr: "C1", exampleDe: "Ungeachtet dessen bleibt die deterministische Integrität gewahrt.", exampleAr: "بصرف النظر عن ذلك، تظل السلامة الحتمية مصونة ومحمية."),
    Vol64DiscourseItem(taskId: 3413, phrase: "in Anbetracht der Tatsache", ipa: "ɪn ˈanbəˌtʁaxt deːɐ̯ ˈtatˌzaxə", arabic: "نظراً لحقيقة أن / بالنظر إلى أن", cefr: "C2", exampleDe: "In Anbetracht der Tatsache bedarf es einer strikten Offline-Prüfung.", exampleAr: "بالنظر إلى هذه الحقيقة، فإن الأمر يتطلب فحصاً صارماً دون اتصال."),
    Vol64DiscourseItem(taskId: 3414, phrase: "demgegenüber", ipa: "deːmɡeːɡn̩ˈʔyːbɐ", arabic: "في المقابل / وخلافاً لذلك", cefr: "C1", exampleDe: "Demgegenüber zeichnet sich das System durch absolute Latenzfreiheit aus.", exampleAr: "في المقابل، يتميز النظام بخلو تام من التأخير الزمني."),
    Vol64DiscourseItem(taskId: 3415, phrase: "gewissermaßen", ipa: "ɡəˈvɪsɐˈmaːsn̩", arabic: "إلى حد ما / بنوع من الاعتبار", cefr: "C1", exampleDe: "Die Architektur bildet gewissermaßen das linguistische Fundament.", exampleAr: "تشكل هذه البنية الهندسية بمثابة الأساس اللغوي للنظام."),
    Vol64DiscourseItem(taskId: 3416, phrase: "nichtsdestoweniger", ipa: "nɪçtsdɛstoːˈveːnɪɡɐ", arabic: "مع ذلك / على أية حال", cefr: "C2", exampleDe: "Nichtsdestoweniger erfordert die Synchronisation permanente Validierung.", exampleAr: "مع ذلك، تتطلب المزامنة تدقيقاً وتحققاً مستمراً."),
    Vol64DiscourseItem(taskId: 3417, phrase: "im Grunde genommen", ipa: "ɪm ˈɡʁʊndə ɡəˈnɔmən", arabic: "في واقع الأمر / جوهرياً", cefr: "B2", exampleDe: "Im Grunde genommen funktioniert die lokale Vektorsuche autonom.", exampleAr: "في واقع الأمر، يعمل محرك البحث الشعاعي المحلي باستقلالية تامة."),
    Vol64DiscourseItem(taskId: 3418, phrase: "strenggenommen", ipa: "ˈʃtʁɛŋɡəˌnɔmən", arabic: "بالمعنى الدقيق / من الناحية الصارمة", cefr: "C1", exampleDe: "Strenggenommen bedarf jeder Zustandsübergang eines kryptografischen Nachweises.", exampleAr: "من الناحية الدقيقة، يحتاج كل انتقال في الحالة إلى إثبات مشفر."),
    Vol64DiscourseItem(taskId: 3419, phrase: "in gewisser Hinsicht", ipa: "ɪn ɡəˈvɪsɐ ˈhɪnzɪçt", arabic: "من وجهة نظر معينة / في جانب من الجوانب", cefr: "B2", exampleDe: "Das Offline-Wörterbuch ist in gewisser Hinsicht unerschöpflich.", exampleAr: "يعتبر القاموس غير المتصل بالإنترنت غير محدود في بعض جوانبه."),
    Vol64DiscourseItem(taskId: 3420, phrase: "vorbehaltlich", ipa: "ˈfoːɐ̯bəˌhaltlɪç", arabic: "بشرط / مع مراعاة ما يلي", cefr: "C2", exampleDe: "Vorbehaltlich technischer Freigaben bleibt der Cache dauerhaft bestehen.", exampleAr: "شريطة الموافقات التقنية، يبقى التخزين المؤقت مستقراً بشكل دائم."),
  ];

  static Vol64DiscourseItem? byTaskId(int id) {
    try {
      return items.firstWhere((e) => e.taskId == id);
    } catch (_) {
      return null;
    }
  }
}
