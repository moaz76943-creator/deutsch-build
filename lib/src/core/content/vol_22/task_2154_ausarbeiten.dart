// Sovereign Polyglot Core - Task 2154 (Software Architecture)
class Task2154Engine {
  static const int taskId = 2154;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'ausarbeiten';
  static const String praeteritum = 'arbeitete aus';
  static const String perfekt = 'hat ausgearbeitet';
  static const String arabicTranslation = 'توسيع / استخراج العمل (هندسة البرمجيات)';
  static const String ipaTranscription = '[ausˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2154_ausarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review ausarbeiten.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج العمل في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
