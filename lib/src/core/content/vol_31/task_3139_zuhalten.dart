// Sovereign Polyglot Core - Task 3139 (Academic Research)
class Task3139Engine {
  static const int taskId = 3139;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'zuhalten';
  static const String praeteritum = 'hielt zu';
  static const String perfekt = 'hat zugehalten';
  static const String arabicTranslation = 'توجيه / إغلاق الالتزام (البحث الأكاديمي)';
  static const String ipaTranscription = '[zuˈˈhaltn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3139_zuhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt zuhalten.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق الالتزام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
