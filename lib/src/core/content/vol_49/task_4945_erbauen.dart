// Sovereign Polyglot Core - Task 4945 (Quality Assurance)
class Task4945Engine {
  static const int taskId = 4945;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'erbauen';
  static const String praeteritum = 'erbaute';
  static const String perfekt = 'hat erbaut';
  static const String arabicTranslation = 'إنجاز / تحقيق التطوير (ضمان الجودة)';
  static const String ipaTranscription = '[erˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4945_erbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess erbauen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التطوير في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
