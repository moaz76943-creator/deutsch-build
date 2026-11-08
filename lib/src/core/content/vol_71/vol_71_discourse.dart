// Generated Substantive Discourse Syntax - Tasks 3621-3630
class Vol71DiscourseItem {
  final int taskId;
  final String phrase;
  final String ipa;
  final String arabic;
  final String cefr;
  final String exampleDe;
  final String exampleAr;

  const Vol71DiscourseItem({
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

class Vol71DiscourseRegistry {
  static const List<Vol71DiscourseItem> items = [
    Vol71DiscourseItem(taskId: 3621, phrase: "zur Genüge dartun", ipa: "tsuːɐ̯ ɡəˈnyːɡə ˈdaːɐ̯ˌtuːn", arabic: "يبيّن بما لا يدع مجالاً للشك / يبرهن بوضوح تام", cefr: "C2", exampleDe: "Die Messergebnisse tun die deterministische Leistung zur Genüge dar.", exampleAr: "تبيّن نتائج القياس الأداء الحتمي للنظام بما لا يدع مجالاً لأدنى شك."),
    Vol71DiscourseItem(taskId: 3622, phrase: "außer Kraft setzen", ipa: "ˈaʊ̯sɐ kʁaft ˈzɛtsn̩", arabic: "يبطل مفعول / يعطل سريان", cefr: "C1", exampleDe: "Lokale Sicherheitsrichtlinien dürfen unter keinen Umständen außer Kraft gesetzt werden.", exampleAr: "لا يجوز تحت أي ظرف من الظروف تعطيل أو إبطال سريان السياسات الأمنية المحلية."),
    Vol71DiscourseItem(taskId: 3623, phrase: "den Schwerpunkt legen auf", ipa: "deːn ˈʃveːɐ̯pʊŋkt ˈleːɡn̩ aʊ̯f", arabic: "يركز الثقل على / يولي الاهتمام الأكبر لـ", cefr: "B2", exampleDe: "Wir legen den Schwerpunkt konsequent auf Offline-Fähigkeit und Datenschutz.", exampleAr: "نحن نركز الثقل والاهتمام الأكبر بشكل مستمر على العمل دون اتصال وحماية البيانات."),
    Vol71DiscourseItem(taskId: 3624, phrase: "in Anspruch nehmen", ipa: "ɪn ˈanʃpʁʊx ˈneːmən", arabic: "يستغرق وقتاً أو جهداً / يستفيد من الخدمة", cefr: "B2", exampleDe: "Die Indexierung nimmt dank Caching nur wenige Millisekunden in Anspruch.", exampleAr: "لا تستغرق الفهرسة بفضل التخزين المؤقت سوى أجزاء ضئيلة من المللي ثانية."),
    Vol71DiscourseItem(taskId: 3625, phrase: "im Klaren sein über", ipa: "ɪm ˈklaːʁən zaɪ̯n ˈyːbɐ", arabic: "يكون على بيّنة تامة من / يدرك بوضوح", cefr: "B2", exampleDe: "Die Entwickler sind sich über die Hardware-Grenzen mobiler Geräte im Klaren.", exampleAr: "المطورون على بيّنة تامة من الحدود العتادية للأجهزة المحمولة."),
    Vol71DiscourseItem(taskId: 3626, phrase: "zur Neige gehen", ipa: "tsuːɐ̯ ˈnaɪ̯ɡə ˈɡeːən", arabic: "يوشك على النفاد / يقترب من النهاية", cefr: "C1", exampleDe: "Bevor der Arbeitsspeicher zur Neige geht, greift die automatische Bereinigung.", exampleAr: "قبل أن توشك الذاكرة على النفاد، تتدخل آلية التنظيف التلقائي فوراً."),
    Vol71DiscourseItem(taskId: 3627, phrase: "auf die lange Bank schieben", ipa: "aʊ̯f diː ˈlaŋə baŋk ˈʃiːbn̩", arabic: "يسوّف / يؤجل دون مبرر", cefr: "B2", exampleDe: "Kritische Sicherheitsupdates dürfen wir niemals auf die lange Bank schieben.", exampleAr: "لا ينبغي لنا أبداً تأجيل التحديثات الأمنية الحيوية أو التسويف فيها."),
    Vol71DiscourseItem(taskId: 3628, phrase: "in Gang setzen", ipa: "ɪn ɡaŋ ˈzɛtsn̩", arabic: "يطلق شرارة البدء / يحرك عجلة العمل", cefr: "B2", exampleDe: "Ein einzelnes Ereignis setzt die gesamte Synchronisationspipeline in Gang.", exampleAr: "يطلق حدث مفرد شرارة البدء لخط معالجة المزامنة بأكمله."),
    Vol71DiscourseItem(taskId: 3629, phrase: "zur Geltung kommen", ipa: "tsuːɐ̯ ˈɡɛltʊŋ ˈkɔmən", arabic: "يبرز أثره بوضوح / يتجلى قدره", cefr: "C1", exampleDe: "Die Vorteile der komprimierten Vektoren kommen bei großen Datenmengen voll zur Geltung.", exampleAr: "تتجلى مزايا المتجهات المضغوطة بوضوح تام عند التعامل مع كميات ضخمة من البيانات."),
    Vol71DiscourseItem(taskId: 3630, phrase: "über den Haufen werfen", ipa: "ˈyːbɐ deːn ˈhaʊ̯fn̩ ˈvɛʁfn̩", arabic: "يقلب المخطط رأساً على عقب / يعيد النظر جذرياً", cefr: "B2", exampleDe: "Unerwartete Profilergebnisse zwangen uns, das Speicherdesign über den Haufen zu werfen.", exampleAr: "أجبرتنا نتائج فحص الأداء غير المتوقعة على إعادة النظر جذرياً في تصميم الذاكرة."),
  ];

  static Vol71DiscourseItem? byTaskId(int id) {
    try {
      return items.firstWhere((e) => e.taskId == id);
    } catch (_) {
      return null;
    }
  }
}
