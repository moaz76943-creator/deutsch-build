// Sovereign Polyglot Core - Task 3313 (Academic Research)
class Task3313Engine {
  static const int taskId = 3313;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'aufschliessen';
  static const String praeteritum = 'schloss auf';
  static const String perfekt = 'hat aufgeschlossen';
  static const String arabicTranslation = 'رفع / فتح الإبرام (البحث الأكاديمي)';
  static const String ipaTranscription = '[aufˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3313_aufschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt aufschliessen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح الإبرام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
