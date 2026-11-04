// Sovereign Polyglot Core - Task 3027 (Academic Research)
class Task3027Engine {
  static const int taskId = 3027;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'umstellen';
  static const String praeteritum = 'stellte um';
  static const String perfekt = 'hat umgestellt';
  static const String arabicTranslation = 'إعادة هيكلة التنظيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[umˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3027_umstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt umstellen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التنظيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
