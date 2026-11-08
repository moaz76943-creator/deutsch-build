// Generated Substantive Discourse Syntax - Tasks 3561-3570
class Vol69DiscourseItem {
  final int taskId;
  final String phrase;
  final String ipa;
  final String arabic;
  final String cefr;
  final String exampleDe;
  final String exampleAr;

  const Vol69DiscourseItem({
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

class Vol69DiscourseRegistry {
  static const List<Vol69DiscourseItem> items = [
    Vol69DiscourseItem(taskId: 3561, phrase: "aus dem Stegreif", ipa: "aʊ̯s deːm ˈʃteːkʁaɪ̯f", arabic: "على البديهة / ارتجالاً دون تحضير", cefr: "B2", exampleDe: "Er übersetzte den komplexen Fachtext mühelos aus dem Stegreif.", exampleAr: "ترجم النص التخصصي المعقد بسلاسة وعلى البديهة دون تحضير مسبق."),
    Vol69DiscourseItem(taskId: 3562, phrase: "in Abrede stehen", ipa: "ɪn aˈbʁeːdə ˈʃteːən", arabic: "يكون محل إنكار / موضع خلاف", cefr: "C2", exampleDe: "Die Relevanz lokaler Offline-Systeme kann nicht in Abrede stehen.", exampleAr: "أهمية الأنظمة المحلية المستقلة لا يمكن أن تكون موضع إنكار أو خلاف."),
    Vol69DiscourseItem(taskId: 3563, phrase: "vor Augen führen", ipa: "foːɐ̯ ˈaʊ̯ɡn̩ ˈfyːʁən", arabic: "يوضح بجلاء / يضع نصب الأعين", cefr: "B2", exampleDe: "Die Telemetriedaten führen uns die exzellente Speichereffizienz vor Augen.", exampleAr: "توضح بيانات القياس كفاءة استهلاك الذاكرة الممتازة بكل جلاء."),
    Vol69DiscourseItem(taskId: 3564, phrase: "zur Genüge wissen", ipa: "tsuːɐ̯ ɡəˈnyːɡə ˈvɪsn̩", arabic: "يعلم علم اليقين / يدرك تمام الإدراك", cefr: "C1", exampleDe: "Entwickler wissen zur Genüge, wie kritisch Netzwerkausfälle sind.", exampleAr: "يعلم المطورون علم اليقين مدى خطورة انقطاعات الشبكة."),
    Vol69DiscourseItem(taskId: 3565, phrase: "den Grundstein legen für", ipa: "deːn ˈɡʁʊntˌʃtaɪ̯n ˈleːɡn̩ fyːɐ̯", arabic: "يضع حجر الأساس لـ / يمهد الطريق لـ", cefr: "B2", exampleDe: "Dieses Modul legt den soliden Grundstein für zukünftige Offline-Features.", exampleAr: "تضع هذه الوحدة البرمجية حجر الأساس المتين للميزات القادمة دون اتصال."),
    Vol69DiscourseItem(taskId: 3566, phrase: "in vollem Umfang", ipa: "ɪn ˈfɔləm ˈʊmfaŋ", arabic: "بكل تفاصيله / بشكل شامل وكامل", cefr: "C1", exampleDe: "Die linguistische Datenbank steht dem Nutzer in vollem Umfang lokal zur Verfügung.", exampleAr: "قاعدة البيانات اللغوية متاحة للمستخدم محلياً بكل تفاصيلها وبشكل كامل."),
    Vol69DiscourseItem(taskId: 3567, phrase: "außer Zweifel stehen", ipa: "ˈaʊ̯sɐ ˈtsvaɪ̯fl̩ ˈʃteːən", arabic: "لا يرقى إليه أدنى شك / مؤكد تماماً", cefr: "C1", exampleDe: "Die Sicherheit kryptografischer Hashfunktionen steht völlig außer Zweifel.", exampleAr: "أمان دوال التجزئة المشفرة أمر مؤكد تماماً ولا يرقى إليه أدنى شك."),
    Vol69DiscourseItem(taskId: 3568, phrase: "Rechenschaft ablegen über", ipa: "ˈʁɛçn̩ʃaft ˈapleːɡn̩ ˈyːbɐ", arabic: "يقدم كشف حساب دقيق عن / يعلل بالتفصيل", cefr: "C1", exampleDe: "Jedes Subsystem muss präzise Rechenschaft über Speicherallokationen ablegen.", exampleAr: "يتعين على كل نظام فرعي تقديم كشف حساب دقيق عن حجز الذاكرة."),
    Vol69DiscourseItem(taskId: 3569, phrase: "in Anschlag bringen", ipa: "ɪn ˈanʃlaːk ˈbʁɪŋən", arabic: "يحتسب في التقدير / يأخذ بعين الحسبان", cefr: "C2", exampleDe: "Bei der Latenzoptimierung müssen wir CPU-Zyklen exakt in Anschlag bringen.", exampleAr: "عند تحسين زمن الاستجابة، يجب أن نحتسب دورات المعالج بدقة متناهية."),
    Vol69DiscourseItem(taskId: 3570, phrase: "die Weichen stellen für", ipa: "diː ˈvaɪ̯çn̩ ˈʃtɛlən fyːɐ̯", arabic: "يرسم مسار المستقبل لـ / يحدد التوجه لـ", cefr: "B2", exampleDe: "Diese Architektur stellt die Weichen für jahrelange Systemstabilität.", exampleAr: "ترسم هذه البنية الهندسية المسار المستقبلي لاستقرار النظام لسنوات طويلة."),
  ];

  static Vol69DiscourseItem? byTaskId(int id) {
    try {
      return items.firstWhere((e) => e.taskId == id);
    } catch (_) {
      return null;
    }
  }
}
