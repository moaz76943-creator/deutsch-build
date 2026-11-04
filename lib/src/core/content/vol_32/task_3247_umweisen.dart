// Sovereign Polyglot Core - Task 3247 (Academic Research)
class Task3247Engine {
  static const int taskId = 3247;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'umweisen';
  static const String praeteritum = 'wies um';
  static const String perfekt = 'hat umgewiesen';
  static const String arabicTranslation = 'إعادة هيكلة التوجيه (البحث الأكاديمي)';
  static const String ipaTranscription = '[umˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3247_umweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt umweisen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التوجيه في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
