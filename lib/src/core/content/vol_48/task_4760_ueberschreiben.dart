// Sovereign Polyglot Core - Task 4760 (Quality Assurance)
class Task4760Engine {
  static const int taskId = 4760;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'ueberschreiben';
  static const String praeteritum = 'ueberschrieb';
  static const String perfekt = 'hat ueberschrieben';
  static const String arabicTranslation = 'مراجعة / نقل التدوين (ضمان الجودة)';
  static const String ipaTranscription = '[ueberˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4760_ueberschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess ueberschreiben.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التدوين في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
