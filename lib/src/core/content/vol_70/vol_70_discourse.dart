// Generated Substantive Discourse Syntax - Tasks 3591-3600
class Vol70DiscourseItem {
  final int taskId;
  final String phrase;
  final String ipa;
  final String arabic;
  final String cefr;
  final String exampleDe;
  final String exampleAr;

  const Vol70DiscourseItem({
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

class Vol70DiscourseRegistry {
  static const List<Vol70DiscourseItem> items = [
    Vol70DiscourseItem(taskId: 3591, phrase: "ins Benehmen setzen mit", ipa: "ɪns bəˈneːmən ˈzɛtsn̩ mɪt", arabic: "يتواصل تشاورياً مع / ينسق مباشرة مع", cefr: "C2", exampleDe: "Das Subsystem setzt sich vor dem Abgleich direkt mit dem Cache ins Benehmen.", exampleAr: "ينسق النظام الفرعي تشاورياً ومباشرة مع الذاكرة المؤقتة قبل المطابقة."),
    Vol70DiscourseItem(taskId: 3592, phrase: "ins Reine bringen", ipa: "ɪns ˈʁaɪ̯nə ˈbʁɪŋən", arabic: "يسوي المسألة جذرياً / يوضح الأمور نهائياً", cefr: "B2", exampleDe: "Wir müssen die Synchronisationskonflikte sofort ins Reine bringen.", exampleAr: "يتعين علينا تسوية تعارضات المزامنة فوراً وبشكل جذري."),
    Vol70DiscourseItem(taskId: 3593, phrase: "Gefallen finden an", ipa: "ɡəˈfaln̩ ˈfɪndn̩ an", arabic: "يستحسن / يجد فيه فائدة ورضا كبيراً", cefr: "B2", exampleDe: "Die Nutzer finden großen Gefallen an der werbefreien Offline-Erfahrung.", exampleAr: "يجد المستخدمون استحساناً ورضا كبيراً في تجربة التعلم الخالية من الإعلانات دون اتصال."),
    Vol70DiscourseItem(taskId: 3594, phrase: "einen Riegel vorschieben", ipa: "ˈaɪ̯nən ˈʁiːɡl̩ ˈfoːɐ̯ˌʃiːbn̩", arabic: "يضع حداً صارماً لـ / يمنع بحزم", cefr: "C1", exampleDe: "Die Architektur schiebt unbefugtem Datenabfluss einen strikten Riegel vor.", exampleAr: "تضع البنية الهندسية حداً صارماً يمنع أي تسريب غير مصرح به للبيانات."),
    Vol70DiscourseItem(taskId: 3595, phrase: "zu Buche schlagen", ipa: "tsuː ˈbuːxə ˈʃlaːɡn̩", arabic: "يؤثر بوضوح على الحصيلة / يترك أثراً حسابياً ملموساً", cefr: "C1", exampleDe: "Effiziente Vektorstrukturen schlagen bei der Akkulaufzeit positiv zu Buche.", exampleAr: "تترك البنى الشعاعية الفعالة أثراً إيجابياً ملموساً على عمر البطارية."),
    Vol70DiscourseItem(taskId: 3596, phrase: "die Oberhand gewinnen", ipa: "diː ˈoːbɐˌhant ɡəˈvɪnn̩", arabic: "تكون له الغلبة / يرجح ويتفوق", cefr: "B2", exampleDe: "Langfristig gewinnt datenschutzfreundliche Software stets die Oberhand.", exampleAr: "على المدى الطويل، تحظى البرمجيات الحامية للخصوصية دائماً بالغلبة والتفوق."),
    Vol70DiscourseItem(taskId: 3597, phrase: "im Dunkeln tappen", ipa: "ɪm ˈdʊŋkl̩n ˈtapn̩", arabic: "يتخبط في غموض / يجهل المسار تماماً", cefr: "B2", exampleDe: "Dank präziser Telemetrie müssen wir bei Performance-Engpässen nie im Dunkeln tappen.", exampleAr: "بفضل القياسات الدقيقة عن بعد، لا نتخبط أبداً في غموض عند تحليل اختناقات الأداء."),
    Vol70DiscourseItem(taskId: 3598, phrase: "zu Tage treten", ipa: "tsuː ˈtaːɡə ˈtʁeːtn̩", arabic: "يبرز بوضوح للعيان / يتكشف جلياً", cefr: "C1", exampleDe: "Bei Stresstests treten architektonische Schwachstellen sofort zu Tage.", exampleAr: "في اختبارات الضغط القصوى، تتكشف أي نقاط ضعف معمارية بوضوح تام."),
    Vol70DiscourseItem(taskId: 3599, phrase: "aus den Fugen geraten", ipa: "aʊ̯s deːn ˈfuːɡn̩ ɡəˈʁaːtn̩", arabic: "يفلت من الضبط / يختل توازنه", cefr: "C1", exampleDe: "Ohne deterministische Queue könnte die Ausführungsreihenfolge aus den Fugen geraten.", exampleAr: "بدون قائمة انتظار حتمية، يمكن لترتيب التنفيذ أن يختل ويفلت من الضبط."),
    Vol70DiscourseItem(taskId: 3600, phrase: "den Nerv der Zeit treffen", ipa: "deːn nɛʁf deːɐ̯ tsaɪ̯t ˈtʁɛfn̩", arabic: "يلامس حاجة العصر / يلبي متطلبات المرحلة بدقة", cefr: "C1", exampleDe: "Vollkommen souveräne Sprachlernsysteme treffen exakt den Nerv der Zeit.", exampleAr: "تلامس منظومات تعلم اللغات المستقلة تماماً حاجة العصر ومتطلبات المرحلة بدقة."),
  ];

  static Vol70DiscourseItem? byTaskId(int id) {
    try {
      return items.firstWhere((e) => e.taskId == id);
    } catch (_) {
      return null;
    }
  }
}
