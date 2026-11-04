// Sovereign Polyglot Core - Task 3306 (Academic Research)
class Task3306Engine {
  static const int taskId = 3306;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'durchteilen';
  static const String praeteritum = 'teilte durch';
  static const String perfekt = 'hat durchgeteilt';
  static const String arabicTranslation = 'إتمام شامل التقسيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[durchˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3306_durchteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt durchteilen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل التقسيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
