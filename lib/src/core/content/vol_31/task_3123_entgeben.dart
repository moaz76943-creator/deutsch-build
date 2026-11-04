// Sovereign Polyglot Core - Task 3123 (Academic Research)
class Task3123Engine {
  static const int taskId = 3123;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'entgeben';
  static const String praeteritum = 'entgab';
  static const String perfekt = 'hat entgeben';
  static const String arabicTranslation = 'استخلاص / كشف التسليم (البحث الأكاديمي)';
  static const String ipaTranscription = '[entˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_3123_entgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt entgeben.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التسليم في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
