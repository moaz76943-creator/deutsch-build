// Generated Substantive Discourse Syntax - Tasks 3711-3720
class Vol74DiscourseItem {
  final int taskId;
  final String phrase;
  final String ipa;
  final String arabic;
  final String cefr;
  final String exampleDe;
  final String exampleAr;

  const Vol74DiscourseItem({
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

class Vol74DiscourseRegistry {
  static const List<Vol74DiscourseItem> items = [
    Vol74DiscourseItem(taskId: 3711, phrase: "in Zweifel ziehen", ipa: "ɪn ˈtsvaɪ̯fl̩ ˈtsiːən", arabic: "يشكك في / يضع موضع تساؤل", cefr: "B2", exampleDe: "Niemand kann die Korrektheit der mathematischen Verifikation in Zweifel ziehen.", exampleAr: "لا يمكن لأحد أن يشكك في صحة ودقة التحقق الرياضي."),
    Vol74DiscourseItem(taskId: 3712, phrase: "zur Schau stellen", ipa: "tsuːɐ̯ ʃaʊ̯ ˈʃtɛlən", arabic: "يستعرض / يظهر علانية", cefr: "C1", exampleDe: "Das System stellt seine herausragende Offline-Stabilität eindrucksvoll zur Schau.", exampleAr: "يستعرض النظام استقراره الفائق دون اتصال بشكل عملي ومبهر."),
    Vol74DiscourseItem(taskId: 3713, phrase: "zum Ausdruck bringen", ipa: "tsʊm ˈaʊ̯sdʁʊk ˈbʁɪŋən", arabic: "يعبّر عن / يجسد بدقة", cefr: "B2", exampleDe: "Die Metriken bringen das tatsächliche Nutzerverhalten präzise zum Ausdruck.", exampleAr: "تجسد المقاييس السلوك الفعلي للمستخدمين بدقة ووضوح تام."),
    Vol74DiscourseItem(taskId: 3714, phrase: "zu Ende führen", ipa: "tsuː ˈɛndə ˈfyːʁən", arabic: "ينجز حتى النهاية / يختتم بنجاح", cefr: "B2", exampleDe: "Wir führen jede gestartete Datenbanktransaktion atomar zu Ende.", exampleAr: "نحن ننجز كل معاملة تبدأ في قاعدة البيانات بشكل ذري حتى النهاية."),
    Vol74DiscourseItem(taskId: 3715, phrase: "auf die Probe stellen", ipa: "aʊ̯f diː ˈpʁoːbə ˈʃtɛlən", arabic: "يضع على المحك / يختبر المتانة", cefr: "B2", exampleDe: "Extreme Lasttests stellen die Ausfallsicherheit täglich auf die Probe.", exampleAr: "تضع اختبارات الضغط القصوى موثوقية النظام على المحك بشكل يومي."),
    Vol74DiscourseItem(taskId: 3716, phrase: "zur Einsicht kommen", ipa: "tsuːɐ̯ ˈaɪ̯nzɪçt ˈkɔmən", arabic: "يصل لقناعة / يدرك بعد تدبر", cefr: "C1", exampleDe: "Jeder Entwickler kommt zur Einsicht, dass lokale Puffer unverzichtbar sind.", exampleAr: "يصل كل مطور إلى قناعة تامة بأن التخزين المؤقت المحلي أمر لا غنى عنه."),
    Vol74DiscourseItem(taskId: 3717, phrase: "in den Schatten stellen", ipa: "ɪn deːn ˈʃatn̩ ˈʃtɛlən", arabic: "يتفوق على / يفوق نظراءه بمراحل", cefr: "B2", exampleDe: "Die neue Vektorextraktion stellt frühere Ansätze weit in den Schatten.", exampleAr: "تفوق طريقة استخراج المتجهات الجديدة كافة المقاربات السابقة بمراحل."),
    Vol74DiscourseItem(taskId: 3718, phrase: "ins Spiel bringen", ipa: "ɪns ʃpiːl ˈbʁɪŋən", arabic: "يطرح خياراً جديداً / يشرك عنصراً فعالاً", cefr: "B2", exampleDe: "Wir bringen zusätzliche phonetische Regeln für schwierige Dialekte ins Spiel.", exampleAr: "نحن نشرك قواعد صوتية إضافية للتعامل مع اللهجات الدقيقة بمرونة."),
    Vol74DiscourseItem(taskId: 3719, phrase: "zu Papier bringen", ipa: "tsuː paˈpiːɐ̯ ˈbʁɪŋən", arabic: "يوثق كتابة / يصوغ كتابياً بدقة", cefr: "B2", exampleDe: "Die Architekturprinzipien müssen klar und unmissverständlich zu Papier gebracht werden.", exampleAr: "يجب صياغة وتوثيق مبادئ البنية المعمارية كتابياً بكل وضوح ودقة."),
    Vol74DiscourseItem(taskId: 3720, phrase: "außer Zweifel setzen", ipa: "ˈaʊ̯sɐ ˈtsvaɪ̯fl̩ ˈzɛtsn̩", arabic: "يقطع الشك باليقين / يثبت قطيعاً", cefr: "C2", exampleDe: "Die kryptografische Signatur setzt die Unverfälschtheit des Pakets außer jeden Zweifel.", exampleAr: "يقطع التوقيع المشفر الشك باليقين بشأن سلامة الحزمة وعدم التلاعب بها."),
  ];

  static Vol74DiscourseItem? byTaskId(int id) {
    try {
      return items.firstWhere((e) => e.taskId == id);
    } catch (_) {
      return null;
    }
  }
}
