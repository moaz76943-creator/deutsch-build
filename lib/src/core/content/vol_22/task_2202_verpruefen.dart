// Sovereign Polyglot Core - Task 2202 (Software Architecture)
class Task2202Engine {
  static const int taskId = 2202;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'verpruefen';
  static const String praeteritum = 'verpruefte';
  static const String perfekt = 'hat verprueft';
  static const String arabicTranslation = 'توثيق / معالجة التدقيق (هندسة البرمجيات)';
  static const String ipaTranscription = '[verˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2202_verpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review verpruefen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التدقيق في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
