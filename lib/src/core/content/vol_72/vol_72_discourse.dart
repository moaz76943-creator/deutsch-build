// Generated Substantive Discourse Syntax - Tasks 3651-3660
class Vol72DiscourseItem {
  final int taskId;
  final String phrase;
  final String ipa;
  final String arabic;
  final String cefr;
  final String exampleDe;
  final String exampleAr;

  const Vol72DiscourseItem({
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

class Vol72DiscourseRegistry {
  static const List<Vol72DiscourseItem> items = [
    Vol72DiscourseItem(taskId: 3651, phrase: "ins Auge fassen", ipa: "ɪns ˈaʊ̯ɡə ˈfasn̩", arabic: "يضع نصب عينيه / يخطط لتنفيذ", cefr: "B2", exampleDe: "Wir fassen eine noch stärkere Speicheroptimierung ins Auge.", exampleAr: "نحن نضع نصب أعيننا تحقيق تحسين أعمق لكفاءة استهلاك الذاكرة."),
    Vol72DiscourseItem(taskId: 3652, phrase: "zu Fall bringen", ipa: "tsuː fal ˈbʁɪŋən", arabic: "يسقط / يطيح بـ / يفشل", cefr: "C1", exampleDe: "Unerwartete Speicherengpässe dürfen das Gesamtsystem niemals zu Fall bringen.", exampleAr: "لا يجوز لاختناقات الذاكرة غير المتوقعة أن تسقط النظام أو تعطل عمله."),
    Vol72DiscourseItem(taskId: 3653, phrase: "ein Ende bereiten", ipa: "aɪ̯n ˈɛndə bəˈʁaɪ̯tn̩", arabic: "يضع نهاية حاسمة لـ", cefr: "B2", exampleDe: "Das neue Format bereitet ineffizienten Datenstrukturen ein rasches Ende.", exampleAr: "تضع الصيغة الجديدة نهاية حاسمة وسريعة للبنى البيانية غير الفعالة."),
    Vol72DiscourseItem(taskId: 3654, phrase: "zur Rechenschaft ziehen", ipa: "tsuːɐ̯ ˈʁɛçn̩ʃaft ˈtsiːən", arabic: "يحاسب / يسائل بدقة", cefr: "C1", exampleDe: "Jeder fehlerhafte Thread wird vom Watchdog sofort zur Rechenschaft gezogen.", exampleAr: "تتم مساءلة وإيقاف أي مسار معالجة معطوب فوراً بواسطة المراقب الآلي."),
    Vol72DiscourseItem(taskId: 3655, phrase: "außer Frage stehen", ipa: "ˈaʊ̯sɐ ˈfʁaːɡə ˈʃteːən", arabic: "لا يرقى إليه أدنى شك / أمر مسلم به", cefr: "C1", exampleDe: "Die Notwendigkeit deterministischer Algorithmen steht völlig außer Frage.", exampleAr: "ضرورة الخوارزميات الحتمية أمر مسلم به ولا يرقى إليه أدنى شك."),
    Vol72DiscourseItem(taskId: 3656, phrase: "ins Leben rufen", ipa: "ɪns ˈleːbn̩ ˈʁuːfn̩", arabic: "يؤسس / يطلق مبادرة أو مشروعاً", cefr: "B2", exampleDe: "Wir haben diese Offline-Plattform für absolute Datensouveränität ins Leben gerufen.", exampleAr: "أطلقنا هذه المنصة غير المتصلة بهدف تحقيق السيادة التامة على البيانات."),
    Vol72DiscourseItem(taskId: 3657, phrase: "den Nagel auf den Kopf treffen", ipa: "deːn ˈnaːɡl̩ aʊ̯f deːn kɔp͡f ˈtʁɛfn̩", arabic: "يصيب عين الصواب / يحدد الجوهر بدقة", cefr: "B2", exampleDe: "Diese modulare Architektur trifft den Nagel präzise auf den Kopf.", exampleAr: "تصيب هذه البنية المعمارية المعيارية عين الصواب بدقة متناهية."),
    Vol72DiscourseItem(taskId: 3658, phrase: "unter Dach und Fach bringen", ipa: "ˈʊntɐ dax ʊnt fax ˈbʁɪŋən", arabic: "ينجز بنجاح تام / يبرم نهائياً", cefr: "B2", exampleDe: "Wir haben die Migration aller Sprachkerne sicher unter Dach und Fach gebracht.", exampleAr: "أنجزنا ترحيل وتأمين كافة النوى اللغوية بنجاح تام وموثق."),
    Vol72DiscourseItem(taskId: 3659, phrase: "die Flinte ins Korn werfen", ipa: "diː ˈflɪntə ɪns kɔʁn ˈvɛʁfn̩", arabic: "يستسلم / يفرط في المحاولة", cefr: "B2", exampleDe: "Auch bei harten Hardware-Restriktionen werfen wir niemals die Flinte ins Korn.", exampleAr: "حتى مع القيود العتادية الصارمة، لن نستسلم أو نتخلى عن الكفاءة العالية."),
    Vol72DiscourseItem(taskId: 3660, phrase: "großen Wert legen auf", ipa: "ˈɡʁoːsn̩ veːɐ̯t ˈleːɡn̩ aʊ̯f", arabic: "يولي قيمة بالغة وأهمية قصوى لـ", cefr: "B2", exampleDe: "Wir legen allergrößten Wert auf kompromisslose Ausführungsgeschwindigkeit.", exampleAr: "نحن نولي سرعة التنفيذ الحتمية الخالية من التنازلات أهمية قصوى."),
  ];

  static Vol72DiscourseItem? byTaskId(int id) {
    try {
      return items.firstWhere((e) => e.taskId == id);
    } catch (_) {
      return null;
    }
  }
}
