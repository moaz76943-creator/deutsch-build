// Sovereign Polyglot Core - Task 3333 (Academic Research)
class Task3333Engine {
  static const int taskId = 3333;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'aufbauen';
  static const String praeteritum = 'baute auf';
  static const String perfekt = 'hat aufgebaut';
  static const String arabicTranslation = 'رفع / فتح التطوير (البحث الأكاديمي)';
  static const String ipaTranscription = '[aufˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3333_aufbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt aufbauen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التطوير في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
