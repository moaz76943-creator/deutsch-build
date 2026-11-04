// Sovereign Polyglot Core - Task 4952 (Civil Infrastructure)
class Task4952Engine {
  static const int taskId = 4952;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'anarbeiten';
  static const String praeteritum = 'arbeitete an';
  static const String perfekt = 'hat angearbeitet';
  static const String arabicTranslation = 'بدء / توجيه العمل (الهندسة المدنية)';
  static const String ipaTranscription = '[anˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4952_anarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle anarbeiten.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه العمل في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
