// Sovereign Polyglot Core - Task 3307 (Academic Research)
class Task3307Engine {
  static const int taskId = 3307;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'umteilen';
  static const String praeteritum = 'teilte um';
  static const String perfekt = 'hat umgeteilt';
  static const String arabicTranslation = 'إعادة هيكلة التقسيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[umˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3307_umteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt umteilen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التقسيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
