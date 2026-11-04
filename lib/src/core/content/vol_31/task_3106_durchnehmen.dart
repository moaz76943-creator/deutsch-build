// Sovereign Polyglot Core - Task 3106 (Academic Research)
class Task3106Engine {
  static const int taskId = 3106;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'durchnehmen';
  static const String praeteritum = 'nahm durch';
  static const String perfekt = 'hat durchgenommen';
  static const String arabicTranslation = 'إتمام شامل الاستلام (البحث الأكاديمي)';
  static const String ipaTranscription = '[durchˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3106_durchnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt durchnehmen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل الاستلام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
