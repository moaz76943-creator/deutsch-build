// Sovereign Polyglot Core - Task 2958 (Academic Research)
class Task2958Engine {
  static const int taskId = 2958;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'vorarbeiten';
  static const String praeteritum = 'arbeitete vor';
  static const String perfekt = 'hat vorgearbeitet';
  static const String arabicTranslation = 'تقديم / تحضير العمل (البحث الأكاديمي)';
  static const String ipaTranscription = '[vorˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2958_vorarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt vorarbeiten.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير العمل في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
