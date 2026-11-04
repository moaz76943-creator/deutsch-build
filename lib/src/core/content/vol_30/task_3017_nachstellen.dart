// Sovereign Polyglot Core - Task 3017 (Academic Research)
class Task3017Engine {
  static const int taskId = 3017;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'nachstellen';
  static const String praeteritum = 'stellte nach';
  static const String perfekt = 'hat nachgestellt';
  static const String arabicTranslation = 'تدقيق / متابعة التنظيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[nachˈˈʃtɛlən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3017_nachstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt nachstellen.';
  static const String exampleArabic = 'يجب علينا تدقيق / متابعة التنظيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
