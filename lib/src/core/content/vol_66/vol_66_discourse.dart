// Generated Substantive Discourse Syntax - Tasks 3471-3480
class Vol66DiscourseItem {
  final int taskId;
  final String phrase;
  final String ipa;
  final String arabic;
  final String cefr;
  final String exampleDe;
  final String exampleAr;

  const Vol66DiscourseItem({
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

class Vol66DiscourseRegistry {
  static const List<Vol66DiscourseItem> items = [
    Vol66DiscourseItem(taskId: 3471, phrase: "demzufolge", ipa: "deːmtsuːˈfɔlɡə", arabic: "وتبعاً لذلك / وبناءً عليه", cefr: "C1", exampleDe: "Demzufolge bleibt die lokale Inferenz vollkommen autonom.", exampleAr: "وتبعاً لذلك، تظل المعالجة الاستنتاجية المحلية مستقلة تماماً."),
    Vol66DiscourseItem(taskId: 3472, phrase: "nichtsdestotrotz", ipa: "nɪçtsdɛstoːˈtʁɔts", arabic: "رغم كل ما سبق / مع ذلك", cefr: "B2", exampleDe: "Nichtsdestotrotz setzen wir den Ausbau der Sprachkerne fort.", exampleAr: "مع ذلك، نواصل توسيع وتطوير النوى اللغوية."),
    Vol66DiscourseItem(taskId: 3473, phrase: "unter dem Vorwand", ipa: "ˈʊntɐ deːm ˈfoːɐ̯vant", arabic: "تحت ذريعة / بحجة", cefr: "C1", exampleDe: "Keine Daten dürfen unter beliebigem Vorwand exportiert werden.", exampleAr: "لا يجوز تصدير أي بيانات تحت أي ذريعة كانت."),
    Vol66DiscourseItem(taskId: 3474, phrase: "im Nachgang zu", ipa: "ɪm ˈnaːxɡaŋ tsuː", arabic: "تعقيباً على / إلحاقاً بـ", cefr: "C1", exampleDe: "Im Nachgang zur Validierung wurde der Speicher bereinigt.", exampleAr: "إلحاقاً بعملية التحقق، تم تنظيف الذاكرة بالكامل."),
    Vol66DiscourseItem(taskId: 3475, phrase: "von vornherein", ipa: "fɔn ˈfɔʁnhɛˌʁaɪ̯n", arabic: "منذ البداية / سلفاً", cefr: "B2", exampleDe: "Fehlerquellen müssen von vornherein ausgeschlossen werden.", exampleAr: "يجب استبعاد مصادر الأخطاء سلفاً ومن البداية."),
    Vol66DiscourseItem(taskId: 3476, phrase: "Hand aufs Herz", ipa: "hant aʊ̯fs hɛʁts", arabic: "بكل صراحة / بصدق وأمانة", cefr: "B2", exampleDe: "Hand aufs Herz: Lokale Modelle bieten die höchste Privatsphäre.", exampleAr: "بكل صدق: النماذج المحلية توفر أعلى مستويات الخصوصية."),
    Vol66DiscourseItem(taskId: 3477, phrase: "im Wesentlichen", ipa: "ɪm ˈveːzn̩tlɪçn̩", arabic: "في جوهره / بصفة أساسية", cefr: "B2", exampleDe: "Das Protokoll stützt sich im Wesentlichen auf Merkle-Bäume.", exampleAr: "يعتمد البروتوكول بصفة أساسية على أشجار ميركل."),
    Vol66DiscourseItem(taskId: 3478, phrase: "unter Ausschluss von", ipa: "ˈʊntɐ ˈaʊ̯sʃlʊs fɔn", arabic: "مع استبعاد تام لـ / دون شمول", cefr: "C1", exampleDe: "Die Verarbeitung erfolgt unter Ausschluss externer Server.", exampleAr: "تتم المعالجة مع استبعاد تام لأي خوادم خارجية."),
    Vol66DiscourseItem(taskId: 3479, phrase: "Maßstäbe setzen", ipa: "ˈmaːsʃtɛːbə ˈzɛtsn̩", arabic: "يرسي معايير رائدة / يحدد مقاييس جديدة", cefr: "C1", exampleDe: "Diese Architektur soll neue Maßstäbe im Offline-Lernen setzen.", exampleAr: "تهدف هذه البنية إلى إرساء معايير جديدة في التعلم غير المتصل."),
    Vol66DiscourseItem(taskId: 3480, phrase: "in Einklang bringen mit", ipa: "ɪn ˈaɪ̯nklaŋ ˈbʁɪŋən mɪt", arabic: "يوفق بين / يجعله متناغماً مع", cefr: "C1", exampleDe: "Wir müssen Systemleistung mit Sparsamkeit in Einklang bringen.", exampleAr: "علينا التوفيق التام بين كفاءة الأداء وترشيد الموارد."),
  ];

  static Vol66DiscourseItem? byTaskId(int id) {
    try {
      return items.firstWhere((e) => e.taskId == id);
    } catch (_) {
      return null;
    }
  }
}
