// Sovereign Polyglot Core - Task 4572 (Quality Assurance)
class Task4572Engine {
  static const int taskId = 4572;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'anplanen';
  static const String praeteritum = 'plante an';
  static const String perfekt = 'hat angeplant';
  static const String arabicTranslation = 'بدء / توجيه التخطيط (ضمان الجودة)';
  static const String ipaTranscription = '[anˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4572_anplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess anplanen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التخطيط في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
