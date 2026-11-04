// Sovereign Polyglot Core - Task 2155 (Software Architecture)
class Task2155Engine {
  static const int taskId = 2155;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'einarbeiten';
  static const String praeteritum = 'arbeitete ein';
  static const String perfekt = 'hat eingearbeitet';
  static const String arabicTranslation = 'إدراج / دمج العمل (هندسة البرمجيات)';
  static const String ipaTranscription = '[einˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2155_einarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review einarbeiten.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج العمل في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
