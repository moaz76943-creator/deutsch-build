// Sovereign Polyglot Core - Task 4661 (Quality Assurance)
class Task4661Engine {
  static const int taskId = 4661;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'unterfuehren';
  static const String praeteritum = 'unterfuehrte';
  static const String perfekt = 'hat unterfuehrt';
  static const String arabicTranslation = 'فحص / دعم الإدارة (ضمان الجودة)';
  static const String ipaTranscription = '[unterˈˈfyːʁən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4661_unterfuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess unterfuehren.';
  static const String exampleArabic = 'يجب علينا فحص / دعم الإدارة في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
