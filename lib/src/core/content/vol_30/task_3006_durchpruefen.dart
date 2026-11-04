// Sovereign Polyglot Core - Task 3006 (Academic Research)
class Task3006Engine {
  static const int taskId = 3006;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'durchpruefen';
  static const String praeteritum = 'pruefte durch';
  static const String perfekt = 'hat durchgeprueft';
  static const String arabicTranslation = 'إتمام شامل التدقيق (البحث الأكاديمي)';
  static const String ipaTranscription = '[durchˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3006_durchpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt durchpruefen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل التدقيق في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
