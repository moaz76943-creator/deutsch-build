// Sovereign Polyglot Core - Task 4965 (Civil Infrastructure)
class Task4965Engine {
  static const int taskId = 4965;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'erarbeiten';
  static const String praeteritum = 'erarbeitete';
  static const String perfekt = 'hat erarbeitet';
  static const String arabicTranslation = 'إنجاز / تحقيق العمل (الهندسة المدنية)';
  static const String ipaTranscription = '[erˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4965_erarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle erarbeiten.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق العمل في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
