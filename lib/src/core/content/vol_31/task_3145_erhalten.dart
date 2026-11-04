// Sovereign Polyglot Core - Task 3145 (Academic Research)
class Task3145Engine {
  static const int taskId = 3145;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'erhalten';
  static const String praeteritum = 'erhielt';
  static const String perfekt = 'hat erhalten';
  static const String arabicTranslation = 'إنجاز / تحقيق الالتزام (البحث الأكاديمي)';
  static const String ipaTranscription = '[erˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3145_erhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt erhalten.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق الالتزام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
