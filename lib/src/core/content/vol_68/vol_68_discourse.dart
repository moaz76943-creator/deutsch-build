// Generated Substantive Discourse Syntax - Tasks 3531-3540
class Vol68DiscourseItem {
  final int taskId;
  final String phrase;
  final String ipa;
  final String arabic;
  final String cefr;
  final String exampleDe;
  final String exampleAr;

  const Vol68DiscourseItem({
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

class Vol68DiscourseRegistry {
  static const List<Vol68DiscourseItem> items = [
    Vol68DiscourseItem(taskId: 3531, phrase: "in Betracht ziehen", ipa: "ɪn bəˈtʁaxt ˈtsiːən", arabic: "يأخذ في الحسبان / يضع في اعتباره", cefr: "B2", exampleDe: "Wir müssen die minimale RAM-Kapazität stets in Betracht ziehen.", exampleAr: "يجب أن نضع سعة الذاكرة المحدودة دائماً في الحسبان."),
    Vol68DiscourseItem(taskId: 3532, phrase: "einen Schlussstrich ziehen", ipa: "ˈaɪ̯nən ˈʃlʊsˌʃtʁɪç ˈtsiːən", arabic: "يضع حداً نهائياً لـ / يطوي الصفحة", cefr: "B2", exampleDe: "Das Projekt zieht einen Schlussstrich unter ungesicherte Cloud-Verbindungen.", exampleAr: "يضع هذا المشروع حداً نهائياً للاتصالات السحابية غير المؤمنة."),
    Vol68DiscourseItem(taskId: 3533, phrase: "außer Acht lassen", ipa: "ˈaʊ̯sɐ axt ˈlasn̩", arabic: "يغفل عن / يهمل مراعاة", cefr: "C1", exampleDe: "Die Akkulaufzeit darf keinesfalls außer Acht gelassen werden.", exampleAr: "لا يجوز بأي حال إغفال استهلاك طاقة البطارية أثناء المعالجة."),
    Vol68DiscourseItem(taskId: 3534, phrase: "unter Beweis stellen", ipa: "ˈʊntɐ bəˈvaɪ̯s ˈʃtɛlən", arabic: "يبرهن عملياً على / يثبت بالدليل", cefr: "B2", exampleDe: "Die Offline-Suche stellt ihre extreme Schnelligkeit täglich unter Beweis.", exampleAr: "يبرهن محرك البحث دون اتصال على سرعته الفائقة يومياً."),
    Vol68DiscourseItem(taskId: 3535, phrase: "in Kraft treten", ipa: "ɪn kʁaft ˈtʁeːtn̩", arabic: "يدخل حيز التنفيذ / يسري مفعوله", cefr: "C1", exampleDe: "Die neuen Optimierungsrichtlinien treten sofort in Kraft.", exampleAr: "تسري قواعد التحسين الجديدة وتدخل حيز التنفيذ فوراً."),
    Vol68DiscourseItem(taskId: 3536, phrase: "zur Anwendung kommen", ipa: "tsuːɐ̯ ˈanvɛndʊŋ ˈkɔmən", arabic: "يجد طريقه للتطبيق / يُطبّق عملياً", cefr: "C1", exampleDe: "Hier kommt ein deterministischer Hash-Algorithmus zur Anwendung.", exampleAr: "يُطبّق هنا خوارزم تجزئة حتمي وعالي الكفاءة."),
    Vol68DiscourseItem(taskId: 3537, phrase: "Abstand nehmen von", ipa: "ˈapʃtant ˈneːmən fɔn", arabic: "يعدل عن / ينأى بنفسه عن", cefr: "C1", exampleDe: "Wir nehmen bewusst Abstand von invasiven Tracking-Methoden.", exampleAr: "نحن ننأى بأنفسنا تماماً وعن قصد عن أساليب التتبع التدخلية."),
    Vol68DiscourseItem(taskId: 3538, phrase: "in Mitleidenschaft ziehen", ipa: "ɪn ˈmɪtlaɪ̯dn̩ʃaft ˈtsiːən", arabic: "يلحق ضرراً بـ / يؤثر سلباً على", cefr: "C1", exampleDe: "Häufige Schreibzugriffe dürfen den Flash-Speicher nicht in Mitleidenschaft ziehen.", exampleAr: "لا يجوز لعمليات الكتابة المتكررة أن تؤثر سلباً على ذاكرة التخزين."),
    Vol68DiscourseItem(taskId: 3539, phrase: "den Vorzug geben", ipa: "deːn ˈfoːɐ̯tsuːk ˈɡeːbn̩", arabic: "يعطي الأولوية لـ / يرجّح كفة", cefr: "C1", exampleDe: "Wir geben lokalen Vektoren stets den absoluten Vorzug.", exampleAr: "نحن نمنح المتجهات المحلية الأولوية المطلقة على الدوام."),
    Vol68DiscourseItem(taskId: 3540, phrase: "ein Urteil fällen über", ipa: "aɪ̯n ˈʊʁtaɪ̯l ˈfɛlən ˈyːbɐ", arabic: "يصدر حكماً موضوعياً بشأن", cefr: "C2", exampleDe: "Der Benutzer kann ein fundiertes Urteil über die Genauigkeit fällen.", exampleAr: "يستطيع المستخدم إصدار حكم موضوعي حول دقة النظام."),
  ];

  static Vol68DiscourseItem? byTaskId(int id) {
    try {
      return items.firstWhere((e) => e.taskId == id);
    } catch (_) {
      return null;
    }
  }
}
