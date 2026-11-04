// Sovereign Polyglot Core - Task 3051 (Academic Research)
class Task3051Engine {
  static const int taskId = 3051;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'abfuehren';
  static const String praeteritum = 'fuehrte ab';
  static const String perfekt = 'hat abgefuehrt';
  static const String arabicTranslation = 'فصل / إتمام الإدارة (البحث الأكاديمي)';
  static const String ipaTranscription = '[abˈˈfyːʁən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3051_abfuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt abfuehren.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الإدارة في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
