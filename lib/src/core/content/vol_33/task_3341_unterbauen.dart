// Sovereign Polyglot Core - Task 3341 (Academic Research)
class Task3341Engine {
  static const int taskId = 3341;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'unterbauen';
  static const String praeteritum = 'unterbaute';
  static const String perfekt = 'hat unterbaut';
  static const String arabicTranslation = 'فحص / دعم التطوير (البحث الأكاديمي)';
  static const String ipaTranscription = '[unterˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3341_unterbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt unterbauen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التطوير في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
