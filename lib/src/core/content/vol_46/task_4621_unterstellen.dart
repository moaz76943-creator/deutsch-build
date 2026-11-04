// Sovereign Polyglot Core - Task 4621 (Quality Assurance)
class Task4621Engine {
  static const int taskId = 4621;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'unterstellen';
  static const String praeteritum = 'unterstellte';
  static const String perfekt = 'hat unterstellt';
  static const String arabicTranslation = 'فحص / دعم التنظيم (ضمان الجودة)';
  static const String ipaTranscription = '[unterˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4621_unterstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess unterstellen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التنظيم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
