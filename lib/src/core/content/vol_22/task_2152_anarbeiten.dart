// Sovereign Polyglot Core - Task 2152 (Software Architecture)
class Task2152Engine {
  static const int taskId = 2152;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'anarbeiten';
  static const String praeteritum = 'arbeitete an';
  static const String perfekt = 'hat angearbeitet';
  static const String arabicTranslation = 'بدء / توجيه العمل (هندسة البرمجيات)';
  static const String ipaTranscription = '[anˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2152_anarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review anarbeiten.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه العمل في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
