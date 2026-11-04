// Sovereign Polyglot Core - Task 3323 (Academic Research)
class Task3323Engine {
  static const int taskId = 3323;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'entschliessen';
  static const String praeteritum = 'entschloss';
  static const String perfekt = 'hat entschlossen';
  static const String arabicTranslation = 'استخلاص / كشف الإبرام (البحث الأكاديمي)';
  static const String ipaTranscription = '[entˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3323_entschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt entschliessen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف الإبرام في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
