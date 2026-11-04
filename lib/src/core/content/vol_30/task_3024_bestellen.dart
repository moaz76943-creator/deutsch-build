// Sovereign Polyglot Core - Task 3024 (Academic Research)
class Task3024Engine {
  static const int taskId = 3024;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'bestellen';
  static const String praeteritum = 'bestellte';
  static const String perfekt = 'hat bestellt';
  static const String arabicTranslation = 'تأكيد / تزويد التنظيم (البحث الأكاديمي)';
  static const String ipaTranscription = '[beˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3024_bestellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt bestellen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التنظيم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
