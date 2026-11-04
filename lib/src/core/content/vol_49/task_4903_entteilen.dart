// Sovereign Polyglot Core - Task 4903 (Quality Assurance)
class Task4903Engine {
  static const int taskId = 4903;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'entteilen';
  static const String praeteritum = 'entteilte';
  static const String perfekt = 'hat entteilt';
  static const String arabicTranslation = 'استخلاص / كشف التقسيم (ضمان الجودة)';
  static const String ipaTranscription = '[entˈˈtaɪ̯lən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4903_entteilen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess entteilen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التقسيم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
