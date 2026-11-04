// Sovereign Polyglot Core - Task 3200 (Academic Research)
class Task3200Engine {
  static const int taskId = 3200;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'ueberziehen';
  static const String praeteritum = 'ueberzog';
  static const String perfekt = 'hat ueberzogen';
  static const String arabicTranslation = 'مراجعة / نقل الاستنتاج (البحث الأكاديمي)';
  static const String ipaTranscription = '[ueberˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3200_ueberziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt ueberziehen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل الاستنتاج في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
