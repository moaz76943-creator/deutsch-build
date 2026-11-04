// Sovereign Polyglot Core - Task 2335 (Software Architecture)
class Task2335Engine {
  static const int taskId = 2335;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'einhalten';
  static const String praeteritum = 'hielt ein';
  static const String perfekt = 'hat eingehalten';
  static const String arabicTranslation = 'إدراج / دمج الالتزام (هندسة البرمجيات)';
  static const String ipaTranscription = '[einˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2335_einhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review einhalten.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج الالتزام في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
