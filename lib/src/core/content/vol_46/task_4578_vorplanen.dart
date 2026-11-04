// Sovereign Polyglot Core - Task 4578 (Quality Assurance)
class Task4578Engine {
  static const int taskId = 4578;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'vorplanen';
  static const String praeteritum = 'plante vor';
  static const String perfekt = 'hat vorgeplant';
  static const String arabicTranslation = 'تقديم / تحضير التخطيط (ضمان الجودة)';
  static const String ipaTranscription = '[vorˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4578_vorplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess vorplanen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التخطيط في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
