// Sovereign Polyglot Core - Task 4782 (Quality Assurance)
class Task4782Engine {
  static const int taskId = 4782;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'versprechen';
  static const String praeteritum = 'versprach';
  static const String perfekt = 'hat versprochen';
  static const String arabicTranslation = 'توثيق / معالجة التخاطب (ضمان الجودة)';
  static const String ipaTranscription = '[verˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4782_versprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess versprechen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة التخاطب في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
