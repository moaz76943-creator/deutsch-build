// Generated Substantive Discourse Syntax - Tasks 3891-3900
class Vol80DiscourseItem {
  final int taskId;
  final String phrase;
  final String ipa;
  final String arabic;
  final String cefr;
  final String exampleDe;
  final String exampleAr;

  const Vol80DiscourseItem({
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

class Vol80DiscourseRegistry {
  static const List<Vol80DiscourseItem> items = [
    Vol80DiscourseItem(taskId: 3891, phrase: "ins rechte Licht rücken", ipa: "ɪns ˈʁɛçtə lɪçt ˈʁʏkn̩", arabic: "يضعه في إطاره الصحيح / يوضح حقيقته", cefr: "B2", exampleDe: "Die Telemetriedaten rücken die enorme Speichereffizienz ins rechte Licht.", exampleAr: "تضع بيانات القياس عن بعد كفاءة استهلاك الذاكرة الفائقة في إطارها الصحيح."),
    Vol80DiscourseItem(taskId: 3892, phrase: "zur Geltung verhelfen", ipa: "tsuːɐ̯ ˈɡɛltʊŋ fɛɐ̯ˈhɛlfn̩", arabic: "يعينه على إبراز قيمته وتحقيق أثره", cefr: "B2", exampleDe: "Die schlanke Architektur verhilft den Offline-Modulen zu maximaler Geltung.", exampleAr: "تعين هذه البنية الرشيقة الوحدات غير المتصلة على تحقيق أقصى فاعلية وأثر."),
    Vol80DiscourseItem(taskId: 3893, phrase: "die Früchte ernten", ipa: "diː ˈfʁʏçtə ˈʔɛʁntn̩", arabic: "يجني ثمار الجهد والعمل الدؤوب", cefr: "B2", exampleDe: "Nach intensiver Optimierung ernten wir die Früchte ladezeitfreier Ausführung.", exampleAr: "بعد التحسين المكثف، نجني ثمار التنفيذ الفوري الخالي من أي زمن انتظار."),
    Vol80DiscourseItem(taskId: 3894, phrase: "ein Zeichen setzen", ipa: "aɪ̯n ˈtsaɪ̯çn̩ ˈzɛtsn̩", arabic: "يعطي إشارة واضحة / يرسي سابقة رائدة", cefr: "B2", exampleDe: "Dieses Projekt setzt ein unübersehbares Zeichen für echte digitale Souveränität.", exampleAr: "يرسي هذا المشروع سابقة رائدة وإشارة واضحة تدعم السيادة الرقمية الحقيقية."),
    Vol80DiscourseItem(taskId: 3895, phrase: "in Gang halten", ipa: "ɪn ɡaŋ ˈhaltn̩", arabic: "يحافظ على استمرار عجلة العمل بنشاط", cefr: "B2", exampleDe: "Der asynchrone Event-Loop hält die Pipeline auch unter Last reibungslos in Gang.", exampleAr: "يحافظ حبل الأحداث غير المتزامن على استمرار تدفق المعالجة بسلاسة حتى تحت الضغط."),
    Vol80DiscourseItem(taskId: 3896, phrase: "vor Anker gehen", ipa: "foːɐ̯ ˈʔaŋkɐ ˈɡeːən", arabic: "يستقر بأمان تام / يرسو بثبات", cefr: "B2", exampleDe: "Die validierten Zustände gehen sicher in der unveränderlichen lokalen Datenbank vor Anker.", exampleAr: "ترسو الحالات المؤكدة بأمان تام واستقرار داخل قاعدة البيانات المحلية غير القابلة للتعديل."),
    Vol80DiscourseItem(taskId: 3897, phrase: "auf die Beine stellen", ipa: "aʊ̯f diː ˈbaɪ̯nə ˈʃtɛlən", arabic: "يؤسس وينجز بنجاح من الصفر", cefr: "B2", exampleDe: "Wir haben ein vollwertiges Offline-System für 100 Sprachen auf die Beine gestellt.", exampleAr: "أسسنا وأنجزنا بنجاح منظومة كاملة للتعلم دون اتصال تشمل 100 لغة من الصفر."),
    Vol80DiscourseItem(taskId: 3898, phrase: "am Ball bleiben", ipa: "am bal ˈblaɪ̯bn̩", arabic: "يواصل المتابعة والتركيز دون انقطاع", cefr: "B2", exampleDe: "Das Entwicklerteam bleibt bei der täglichen Code-Qualität konsequent am Ball.", exampleAr: "يواصل الفريق الهندسي المتابعة الدقيقة والتركيز المستمر على جودة الكود البرمجي."),
    Vol80DiscourseItem(taskId: 3899, phrase: "den Ton angeben", ipa: "deːn toːn ˈanˌɡeːbn̩", arabic: "يحدد النهج القيادي / يقود الركب", cefr: "B2", exampleDe: "In Sachen Datenschutz und Offline-First gibt diese Plattform klar den Ton an.", exampleAr: "في مجال حماية البيانات والعمل دون اتصال، تقود هذه المنصة الركب وتحدد المعايير."),
    Vol80DiscourseItem(taskId: 3900, phrase: "in Stein gemeißelt sein", ipa: "ɪn ʃtaɪ̯n ɡəˈmaɪ̯sl̩t zaɪ̯n", arabic: "ثابت لا يتغير / غير قابل للتبديل", cefr: "C1", exampleDe: "Das Prinzip der absoluten Zero-Telemetry ist in der Architektur wie in Stein gemeißelt.", exampleAr: "إن مبدأ الخلو التام من التتبع الخارجي راسخ في البنية المعمارية كأنه منقوش في الحجر."),
  ];

  static Vol80DiscourseItem? byTaskId(int id) {
    try {
      return items.firstWhere((e) => e.taskId == id);
    } catch (_) {
      return null;
    }
  }
}
