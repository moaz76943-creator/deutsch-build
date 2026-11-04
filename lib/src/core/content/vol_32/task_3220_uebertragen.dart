// Sovereign Polyglot Core - Task 3220 (Academic Research)
class Task3220Engine {
  static const int taskId = 3220;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'uebertragen';
  static const String praeteritum = 'uebertrug';
  static const String perfekt = 'hat uebertragen';
  static const String arabicTranslation = 'مراجعة / نقل المسؤولية (البحث الأكاديمي)';
  static const String ipaTranscription = '[ueberˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3220_uebertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt uebertragen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل المسؤولية في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
