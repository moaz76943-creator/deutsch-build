// Sovereign Polyglot Core - Task 3011 (Academic Research)
class Task3011Engine {
  static const int taskId = 3011;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'abstellen';
  static const String praeteritum = 'stellte ab';
  static const String perfekt = 'hat abgestellt';
  static const String arabicTranslation = 'فصل / إتمام التنظيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[abˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3011_abstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt abstellen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التنظيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
