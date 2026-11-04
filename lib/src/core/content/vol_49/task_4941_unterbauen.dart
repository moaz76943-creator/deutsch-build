// Sovereign Polyglot Core - Task 4941 (Quality Assurance)
class Task4941Engine {
  static const int taskId = 4941;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'unterbauen';
  static const String praeteritum = 'unterbaute';
  static const String perfekt = 'hat unterbaut';
  static const String arabicTranslation = 'فحص / دعم التطوير (ضمان الجودة)';
  static const String ipaTranscription = '[unterˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4941_unterbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess unterbauen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التطوير في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
