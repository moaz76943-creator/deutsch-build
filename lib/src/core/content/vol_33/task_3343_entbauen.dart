// Sovereign Polyglot Core - Task 3343 (Academic Research)
class Task3343Engine {
  static const int taskId = 3343;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'entbauen';
  static const String praeteritum = 'entbaute';
  static const String perfekt = 'hat entbaut';
  static const String arabicTranslation = 'استخلاص / كشف التطوير (البحث الأكاديمي)';
  static const String ipaTranscription = '[entˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3343_entbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt entbauen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التطوير في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
