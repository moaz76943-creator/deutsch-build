// Sovereign Polyglot Core - Task 4261 (Supply Chain)
class Task4261Engine {
  static const int taskId = 4261;
  static const String domain = 'Supply Chain';
  static const String verbInfinitive = 'unterfuehren';
  static const String praeteritum = 'unterfuehrte';
  static const String perfekt = 'hat unterfuehrt';
  static const String arabicTranslation = 'فحص / دعم الإدارة (سلاسل الإمداد)';
  static const String ipaTranscription = '[unterˈˈfyːʁən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4261_unterfuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Logistikzentrale unterfuehren.';
  static const String exampleArabic = 'يجب علينا فحص / دعم الإدارة في مركز العمليات اللوجستية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
