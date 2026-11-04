// Sovereign Polyglot Core - Task 2965 (Academic Research)
class Task2965Engine {
  static const int taskId = 2965;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'erarbeiten';
  static const String praeteritum = 'erarbeitete';
  static const String perfekt = 'hat erarbeitet';
  static const String arabicTranslation = 'إنجاز / تحقيق العمل (البحث الأكاديمي)';
  static const String ipaTranscription = '[erˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2965_erarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt erarbeiten.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق العمل في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
