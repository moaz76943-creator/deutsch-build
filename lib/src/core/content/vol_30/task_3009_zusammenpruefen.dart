// Sovereign Polyglot Core - Task 3009 (Academic Research)
class Task3009Engine {
  static const int taskId = 3009;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'zusammenpruefen';
  static const String praeteritum = 'pruefte zusammen';
  static const String perfekt = 'hat zusammengeprueft';
  static const String arabicTranslation = 'تجميع / توحيد التدقيق (البحث الأكاديمي)';
  static const String ipaTranscription = '[zusammenˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3009_zusammenpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt zusammenpruefen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التدقيق في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
