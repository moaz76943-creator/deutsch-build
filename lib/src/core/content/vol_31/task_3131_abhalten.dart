// Sovereign Polyglot Core - Task 3131 (Academic Research)
class Task3131Engine {
  static const int taskId = 3131;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'abhalten';
  static const String praeteritum = 'hielt ab';
  static const String perfekt = 'hat abgehalten';
  static const String arabicTranslation = 'فصل / إتمام الالتزام (البحث الأكاديمي)';
  static const String ipaTranscription = '[abˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3131_abhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt abhalten.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام الالتزام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
