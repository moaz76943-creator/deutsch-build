// Sovereign Polyglot Core - Task 4611 (Quality Assurance)
class Task4611Engine {
  static const int taskId = 4611;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'abstellen';
  static const String praeteritum = 'stellte ab';
  static const String perfekt = 'hat abgestellt';
  static const String arabicTranslation = 'فصل / إتمام التنظيم (ضمان الجودة)';
  static const String ipaTranscription = '[abˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4611_abstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess abstellen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التنظيم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
