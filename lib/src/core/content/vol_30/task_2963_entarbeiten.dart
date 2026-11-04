// Sovereign Polyglot Core - Task 2963 (Academic Research)
class Task2963Engine {
  static const int taskId = 2963;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'entarbeiten';
  static const String praeteritum = 'entarbeitete';
  static const String perfekt = 'hat entarbeitet';
  static const String arabicTranslation = 'استخلاص / كشف العمل (البحث الأكاديمي)';
  static const String ipaTranscription = '[entˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2963_entarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt entarbeiten.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف العمل في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
