// Sovereign Polyglot Core - Task 3295 (Academic Research)
class Task3295Engine {
  static const int taskId = 3295;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'einteilen';
  static const String praeteritum = 'teilte ein';
  static const String perfekt = 'hat eingeteilt';
  static const String arabicTranslation = 'إدراج / دمج التقسيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[einˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3295_einteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt einteilen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التقسيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
