// Sovereign Polyglot Core - Task 3151 (Academic Research)
class Task3151Engine {
  static const int taskId = 3151;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'abschreiben';
  static const String praeteritum = 'schrieb ab';
  static const String perfekt = 'hat abgeschrieben';
  static const String arabicTranslation = 'فصل / إتمام التدوين (البحث الأكاديمي)';
  static const String ipaTranscription = '[abˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3151_abschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt abschreiben.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التدوين في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
