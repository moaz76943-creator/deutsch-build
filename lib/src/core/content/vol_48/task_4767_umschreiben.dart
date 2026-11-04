// Sovereign Polyglot Core - Task 4767 (Quality Assurance)
class Task4767Engine {
  static const int taskId = 4767;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'umschreiben';
  static const String praeteritum = 'schrieb um';
  static const String perfekt = 'hat umgeschrieben';
  static const String arabicTranslation = 'إعادة هيكلة التدوين (ضمان الجودة)';
  static const String ipaTranscription = '[umˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4767_umschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess umschreiben.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التدوين في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
