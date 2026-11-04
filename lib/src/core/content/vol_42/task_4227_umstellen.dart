// Sovereign Polyglot Core - Task 4227 (Supply Chain)
class Task4227Engine {
  static const int taskId = 4227;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'umstellen';
  static const String praeteritum = 'stellte um';
  static const String perfekt = 'hat umgestellt';
  static const String arabicTranslation = 'إعادة هيكلة التنظيم (سلاسل الإمداد)';
  static const String ipaTranscription = '[umˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4227_umstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale umstellen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التنظيم في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
