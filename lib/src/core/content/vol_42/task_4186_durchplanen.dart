// Sovereign Polyglot Core - Task 4186 (Supply Chain)
class Task4186Engine {
  static const int taskId = 4186;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'durchplanen';
  static const String praeteritum = 'plante durch';
  static const String perfekt = 'hat durchgeplant';
  static const String arabicTranslation = 'إتمام شامل التخطيط (سلاسل الإمداد)';
  static const String ipaTranscription = '[durchˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4186_durchplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale durchplanen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل التخطيط في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
