// Sovereign Polyglot Core - Task 2227 (Software Architecture)
class Task2227Engine {
  static const int taskId = 2227;
  static const String domain = 'Software Architecture';
  static const String verbInfinitive = 'umstellen';
  static const String praeteritum = 'stellte um';
  static const String perfekt = 'hat umgestellt';
  static const String arabicTranslation = 'إعادة هيكلة التنظيم (هندسة البرمجيات)';
  static const String ipaTranscription = '[umˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_2227_umstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Architektur-Review umstellen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التنظيم في مراجعة هندسة النظام.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
