// Sovereign Polyglot Core - Task 4581 (Quality Assurance)
class Task4581Engine {
  static const int taskId = 4581;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'unterplanen';
  static const String praeteritum = 'unterplante';
  static const String perfekt = 'hat unterplant';
  static const String arabicTranslation = 'فحص / دعم التخطيط (ضمان الجودة)';
  static const String ipaTranscription = '[unterˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4581_unterplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess unterplanen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التخطيط في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
