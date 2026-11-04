// Sovereign Polyglot Core - Task 4753 (Quality Assurance)
class Task4753Engine {
  static const int taskId = 4753;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'aufschreiben';
  static const String praeteritum = 'schrieb auf';
  static const String perfekt = 'hat aufgeschrieben';
  static const String arabicTranslation = 'رفع / فتح التدوين (ضمان الجودة)';
  static const String ipaTranscription = '[aufˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4753_aufschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess aufschreiben.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التدوين في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
