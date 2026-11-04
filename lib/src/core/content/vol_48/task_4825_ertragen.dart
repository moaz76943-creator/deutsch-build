// Sovereign Polyglot Core - Task 4825 (Quality Assurance)
class Task4825Engine {
  static const int taskId = 4825;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'ertragen';
  static const String praeteritum = 'ertrug';
  static const String perfekt = 'hat ertragen';
  static const String arabicTranslation = 'إنجاز / تحقيق المسؤولية (ضمان الجودة)';
  static const String ipaTranscription = '[erˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4825_ertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess ertragen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق المسؤولية في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
