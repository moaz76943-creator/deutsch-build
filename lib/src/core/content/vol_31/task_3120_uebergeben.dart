// Sovereign Polyglot Core - Task 3120 (Academic Research)
class Task3120Engine {
  static const int taskId = 3120;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'uebergeben';
  static const String praeteritum = 'uebergab';
  static const String perfekt = 'hat uebergeben';
  static const String arabicTranslation = 'مراجعة / نقل التسليم (البحث الأكاديمي)';
  static const String ipaTranscription = '[ueberˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3120_uebergeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt uebergeben.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التسليم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
