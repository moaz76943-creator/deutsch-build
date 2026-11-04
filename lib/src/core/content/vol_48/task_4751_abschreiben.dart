// Sovereign Polyglot Core - Task 4751 (Quality Assurance)
class Task4751Engine {
  static const int taskId = 4751;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'abschreiben';
  static const String praeteritum = 'schrieb ab';
  static const String perfekt = 'hat abgeschrieben';
  static const String arabicTranslation = 'فصل / إتمام التدوين (ضمان الجودة)';
  static const String ipaTranscription = '[abˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4751_abschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess abschreiben.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التدوين في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
