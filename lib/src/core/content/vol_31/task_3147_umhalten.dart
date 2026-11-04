// Sovereign Polyglot Core - Task 3147 (Academic Research)
class Task3147Engine {
  static const int taskId = 3147;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'umhalten';
  static const String praeteritum = 'hielt um';
  static const String perfekt = 'hat umgehalten';
  static const String arabicTranslation = 'إعادة هيكلة الالتزام (البحث الأكاديمي)';
  static const String ipaTranscription = '[umˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3147_umhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt umhalten.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة الالتزام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
