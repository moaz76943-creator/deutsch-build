// Sovereign Polyglot Core - Task 3063 (Academic Research)
class Task3063Engine {
  static const int taskId = 3063;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'entfuehren';
  static const String praeteritum = 'entfuehrte';
  static const String perfekt = 'hat entfuehrt';
  static const String arabicTranslation = 'استخلاص / كشف الإدارة (البحث الأكاديمي)';
  static const String ipaTranscription = '[entˈˈfyːʁən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3063_entfuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt entfuehren.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف الإدارة في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
