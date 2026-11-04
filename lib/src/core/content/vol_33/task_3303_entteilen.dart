// Sovereign Polyglot Core - Task 3303 (Academic Research)
class Task3303Engine {
  static const int taskId = 3303;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'entteilen';
  static const String praeteritum = 'entteilte';
  static const String perfekt = 'hat entteilt';
  static const String arabicTranslation = 'استخلاص / كشف التقسيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[entˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3303_entteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt entteilen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التقسيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
