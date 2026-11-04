// Sovereign Polyglot Core - Task 4763 (Quality Assurance)
class Task4763Engine {
  static const int taskId = 4763;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'entschreiben';
  static const String praeteritum = 'entschrieb';
  static const String perfekt = 'hat entschrieben';
  static const String arabicTranslation = 'استخلاص / كشف التدوين (ضمان الجودة)';
  static const String ipaTranscription = '[entˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4763_entschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess entschreiben.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التدوين في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
