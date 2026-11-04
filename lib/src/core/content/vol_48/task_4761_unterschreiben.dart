// Sovereign Polyglot Core - Task 4761 (Quality Assurance)
class Task4761Engine {
  static const int taskId = 4761;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'unterschreiben';
  static const String praeteritum = 'unterschrieb';
  static const String perfekt = 'hat unterschrieben';
  static const String arabicTranslation = 'فحص / دعم التدوين (ضمان الجودة)';
  static const String ipaTranscription = '[unterˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4761_unterschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess unterschreiben.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التدوين في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
