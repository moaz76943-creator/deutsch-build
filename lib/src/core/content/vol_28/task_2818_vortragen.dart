// Sovereign Polyglot Core - Task 2818 (Clinical Diagnostics)
class Task2818Engine {
  static const int taskId = 2818;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'vortragen';
  static const String praeteritum = 'trug vor';
  static const String perfekt = 'hat vorgetragen';
  static const String arabicTranslation = 'تقديم / تحضير المسؤولية (التواصل الطبي)';
  static const String ipaTranscription = '[vorˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2818_vortragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung vortragen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير المسؤولية في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
