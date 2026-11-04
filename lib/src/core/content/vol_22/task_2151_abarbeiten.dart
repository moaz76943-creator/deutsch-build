// Sovereign Polyglot Core - Task 2151 (Software Architecture)
class Task2151Engine {
  static const int taskId = 2151;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'abarbeiten';
  static const String praeteritum = 'arbeitete ab';
  static const String perfekt = 'hat abgearbeitet';
  static const String arabicTranslation = 'فصل / إتمام العمل (هندسة البرمجيات)';
  static const String ipaTranscription = '[abˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2151_abarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review abarbeiten.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام العمل في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
