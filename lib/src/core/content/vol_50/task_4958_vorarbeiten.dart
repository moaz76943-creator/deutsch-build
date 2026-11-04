// Sovereign Polyglot Core - Task 4958 (Civil Infrastructure)
class Task4958Engine {
  static const int taskId = 4958;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'vorarbeiten';
  static const String praeteritum = 'arbeitete vor';
  static const String perfekt = 'hat vorgearbeitet';
  static const String arabicTranslation = 'تقديم / تحضير العمل (الهندسة المدنية)';
  static const String ipaTranscription = '[vorˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4958_vorarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle vorarbeiten.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير العمل في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
