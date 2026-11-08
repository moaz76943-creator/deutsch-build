// Generated Substantive Discourse Syntax - Tasks 3441-3450
class Vol65DiscourseItem {
  final int taskId;
  final String phrase;
  final String ipa;
  final String arabic;
  final String cefr;
  final String exampleDe;
  final String exampleAr;

  const Vol65DiscourseItem({
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

class Vol65DiscourseRegistry {
  static const List<Vol65DiscourseItem> items = [
    Vol65DiscourseItem(taskId: 3441, phrase: "geschweige denn", ipa: "ɡəˈʃvaɪ̯ɡə dɛn", arabic: "فضلًا عن / ناهيك عن", cefr: "C1", exampleDe: "Er kennt die Grundlagen kaum, geschweige denn die komplexe Syntax.", exampleAr: "هو بالكاد يعرف المبادئ، فضلًا عن البنية النحوية المعقدة."),
    Vol65DiscourseItem(taskId: 3442, phrase: "sei es ..., sei es ...", ipa: "zaɪ̯ ɛs ..., zaɪ̯ ɛs ...", arabic: "سواء كان ... أو ...", cefr: "C1", exampleDe: "Sei es im Speicher oder auf der Festplatte, die Integrität bleibt gewahrt.", exampleAr: "سواء كان ذلك في الذاكرة أو على القرص، تظل السلامة مصونة."),
    Vol65DiscourseItem(taskId: 3443, phrase: "in Anlehnung an", ipa: "ɪn ˈanleːnʊŋ an", arabic: "استناداً إلى / تماشياً مع", cefr: "C1", exampleDe: "Die Architektur wurde in Anlehnung an bewährte Standards entworfen.", exampleAr: "صُممت البنية المعمارية استناداً إلى المعايير المعتمدة والمثبتة."),
    Vol65DiscourseItem(taskId: 3444, phrase: "kraft dessen", ipa: "kʁaft ˈdɛsn̩", arabic: "بموجب ذلك / بقوة ذلك", cefr: "C2", exampleDe: "Ein striktes Regelwerk, kraft dessen alle Konflikte lokal gelöst werden.", exampleAr: "منظومة قواعد صارمة يُحل بموجبها كل تعارض محلياً."),
    Vol65DiscourseItem(taskId: 3445, phrase: "in Abrede stellen", ipa: "ɪn aˈbʁeːdə ˈʃtɛlən", arabic: "ينكر / يطعن في صحة", cefr: "C2", exampleDe: "Niemand kann die Robustheit der Offline-Infrastruktur in Abrede stellen.", exampleAr: "لا يمكن لأحد أن يطعن في متانة البنية التحتية غير المتصلة."),
    Vol65DiscourseItem(taskId: 3446, phrase: "zur Einsicht gelangen", ipa: "tsuːɐ̯ ˈaɪ̯nzɪçt ɡəˈlaŋən", arabic: "يتوصل إلى قناعة / يدرك تماماً", cefr: "C1", exampleDe: "Das Entwicklerteam gelangte zur Einsicht, dass Caching unerlässlich ist.", exampleAr: "توصل الفريق الهندسي إلى قناعة تامة بأن التخزين المؤقت ضرورة حتمية."),
    Vol65DiscourseItem(taskId: 3447, phrase: "in Erwägung ziehen", ipa: "ɪn ɛɐ̯ˈvɛːɡʊŋ ˈtsiːən", arabic: "يأخذ بعين الاعتبار / يدرس إمكانية", cefr: "C1", exampleDe: "Wir müssen alternative Komprimierungsverfahren in Erwägung ziehen.", exampleAr: "يتعين علينا أن نأخذ خوارزميات الضغط البديلة بعين الاعتبار."),
    Vol65DiscourseItem(taskId: 3448, phrase: "Aufschluss geben über", ipa: "ˈaʊ̯fʃlʊs ˈɡeːbn̩ ˈyːbɐ", arabic: "يسلّط الضوء على / يقدم دليلاً واضحاً عن", cefr: "C1", exampleDe: "Die Telemetrieberichte geben Aufschluss über das Systemverhalten.", exampleAr: "تقدم تقارير القياس عن بعد دليلاً واضحاً يوضح سلوك النظام."),
    Vol65DiscourseItem(taskId: 3449, phrase: "in den Vordergrund rücken", ipa: "ɪn deːn ˈfɔʁdɐɡʁʊnt ˈʁʏkn̩", arabic: "يتصدر الأولوية / يبرز في المقدمة", cefr: "B2", exampleDe: "Datenschutz und Datenhoheit rücken stets in den Vordergrund.", exampleAr: "تتصدر حماية البيانات والسيادة الرقمية دائماً أولويات العمل."),
    Vol65DiscourseItem(taskId: 3450, phrase: "Schritt halten mit", ipa: "ʃʁɪt ˈhaltn̩ mɪt", arabic: "يواكب / يتماشى مع خطى التطور", cefr: "B2", exampleDe: "Das Offline-System kann mühelos mit modernen Standards Schritt halten.", exampleAr: "يستطيع النظام غير المتصل أن يواكب المعايير الحديثة بكل سلاسة."),
  ];

  static Vol65DiscourseItem? byTaskId(int id) {
    try {
      return items.firstWhere((e) => e.taskId == id);
    } catch (_) {
      return null;
    }
  }
}
