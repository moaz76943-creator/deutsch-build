// Generated Substantive Discourse Syntax - Tasks 3501-3510
class Vol67DiscourseItem {
  final int taskId;
  final String phrase;
  final String ipa;
  final String arabic;
  final String cefr;
  final String exampleDe;
  final String exampleAr;

  const Vol67DiscourseItem({
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

class Vol67DiscourseRegistry {
  static const List<Vol67DiscourseItem> items = [
    Vol67DiscourseItem(taskId: 3501, phrase: "hinfällig werden", ipa: "ˈhɪnˌfɛlɪç ˈveːɐ̯dn̩", arabic: "يصبح لاغياً / يفقد جدواه", cefr: "C1", exampleDe: "Durch die lokale Speicherung werden Cloud-Abhängigkeiten hinfällig.", exampleAr: "بفضل التخزين المحلي، تصبح التبعية السحابية ملغاة تماماً."),
    Vol67DiscourseItem(taskId: 3502, phrase: "ins Gewicht fallen", ipa: "ɪns ɡəˈvɪçt ˈfaln̩", arabic: "يرجح كفته / يكون ذا بال وأهمية", cefr: "B2", exampleDe: "Die Latenzzeit fällt bei Echtzeitanwendungen stark ins Gewicht.", exampleAr: "زمن الاستجابة يكتسب أهمية بالغة في تطبيقات الوقت الفعلي."),
    Vol67DiscourseItem(taskId: 3503, phrase: "über die Runden kommen", ipa: "ˈyːbɐ diː ˈʁʊndn̩ ˈkɔmən", arabic: "يتدبر أمره بمرونة / يجتاز التحديات", cefr: "B2", exampleDe: "Das System kommt auch bei minimalem Arbeitsspeicher gut über die Runden.", exampleAr: "يتدبر النظام أمره بكفاءة حتى مع الحد الأدنى من الذاكرة العشوائية."),
    Vol67DiscourseItem(taskId: 3504, phrase: "einen Konsens erzielen", ipa: "ˈaɪ̯nən kɔnˈzɛns ɛɐ̯ˈtsiːlən", arabic: "يحقق توافقاً / يتوصل لإجماع", cefr: "C1", exampleDe: "Die dezentralen Knoten erzielen ohne Mittler einen deterministischen Konsens.", exampleAr: "تحقق العقد اللامركزية توافقاً حتمياً دون الحاجة إلى وسيط."),
    Vol67DiscourseItem(taskId: 3505, phrase: "den Ausschlag geben", ipa: "deːn ˈaʊ̯sˌʃlaːk ˈɡeːbn̩", arabic: "يكون العامل الحاسم / يرجّح القرار", cefr: "C1", exampleDe: "Die absolute Datensouveränität gibt für das Projekt den Ausschlag.", exampleAr: "السيادة المطلقة على البيانات هي التي تشكل العامل الحاسم في المشروع."),
    Vol67DiscourseItem(taskId: 3506, phrase: "in vollem Gange sein", ipa: "ɪn ˈfɔləm ˈɡaŋə zaɪ̯n", arabic: "على قدم وساق / في ذروة نشاطه", cefr: "B2", exampleDe: "Die Vorbereitung der Offline-Sprachpakete ist in vollem Gange.", exampleAr: "تجهيز حزم اللغات دون اتصال يجري الآن على قدم وساق."),
    Vol67DiscourseItem(taskId: 3507, phrase: "zur Sprache bringen", ipa: "tsuːɐ̯ ˈʃpʁaːxə ˈbʁɪŋən", arabic: "يطرح للنقاش / يثير المسألة بدقة", cefr: "B2", exampleDe: "Wir müssen die Performance-Optimierung im nächsten Sprint zur Sprache bringen.", exampleAr: "يتعين علينا طرح مسألة تحسين الأداء للنقاش في المرحلة القادمة."),
    Vol67DiscourseItem(taskId: 3508, phrase: "von Belang sein", ipa: "fɔn bəˈlaŋ zaɪ̯n", arabic: "ذو أهمية واعتبار / بالغ الأثر", cefr: "C1", exampleDe: "Jede einzelne phonetische Nuance ist für die Sprachsynthese von Belang.", exampleAr: "كل فارق صوتي دقيق يعد ذا أهمية واعتبار في التوليف الصوتي."),
    Vol67DiscourseItem(taskId: 3509, phrase: "zu Bedauern Anlass geben", ipa: "tsuː bəˈdaʊ̯ɐn ˈanlas ˈɡeːbn̩", arabic: "يدعو إلى الأسف / يستوجب التدارك", cefr: "C2", exampleDe: "Datenverluste geben stets zu tiefstem Bedauern Anlass.", exampleAr: "فقدان البيانات أمر يدعو للأسف الشديد ويستوجب التدقيق الحازم."),
    Vol67DiscourseItem(taskId: 3510, phrase: "außer Streit stehen", ipa: "ˈaʊ̯sɐ ʃtʁaɪ̯t ˈʃteːən", arabic: "لا خلاف حوله / أمر غير قابل للجدل", cefr: "C2", exampleDe: "Die Unantastbarkeit der Privatsphäre steht völlig außer Streit.", exampleAr: "حرمة الخصوصية التامة أمر محسوم ولا خلاف حوله إطلاقاً."),
  ];

  static Vol67DiscourseItem? byTaskId(int id) {
    try {
      return items.firstWhere((e) => e.taskId == id);
    } catch (_) {
      return null;
    }
  }
}
