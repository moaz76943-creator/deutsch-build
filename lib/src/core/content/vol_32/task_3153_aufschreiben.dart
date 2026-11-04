// Sovereign Polyglot Core - Task 3153 (Academic Research)
class Task3153Engine {
  static const int taskId = 3153;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'aufschreiben';
  static const String praeteritum = 'schrieb auf';
  static const String perfekt = 'hat aufgeschrieben';
  static const String arabicTranslation = 'رفع / فتح التدوين (البحث الأكاديمي)';
  static const String ipaTranscription = '[aufˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3153_aufschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt aufschreiben.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التدوين في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
