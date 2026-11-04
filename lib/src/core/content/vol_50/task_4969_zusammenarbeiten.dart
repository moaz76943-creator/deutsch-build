// Sovereign Polyglot Core - Task 4969 (Civil Infrastructure)
class Task4969Engine {
  static const int taskId = 4969;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'zusammenarbeiten';
  static const String praeteritum = 'arbeitete zusammen';
  static const String perfekt = 'hat zusammengearbeitet';
  static const String arabicTranslation = 'تجميع / توحيد العمل (الهندسة المدنية)';
  static const String ipaTranscription = '[zusammenˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4969_zusammenarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle zusammenarbeiten.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد العمل في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
