// Sovereign Polyglot Core - Task 3040 (Academic Research)
class Task3040Engine {
  static const int taskId = 3040;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'ueberlegen';
  static const String praeteritum = 'ueberlegte';
  static const String perfekt = 'hat ueberlegt';
  static const String arabicTranslation = 'مراجعة / نقل التأسيس (البحث الأكاديمي)';
  static const String ipaTranscription = '[ueberˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3040_ueberlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt ueberlegen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التأسيس في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
