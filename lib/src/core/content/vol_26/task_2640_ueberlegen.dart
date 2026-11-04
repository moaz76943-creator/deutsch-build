// Sovereign Polyglot Core - Task 2640 (Clinical Diagnostics)
class Task2640Engine {
  static const int taskId = 2640;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ueberlegen';
  static const String praeteritum = 'ueberlegte';
  static const String perfekt = 'hat ueberlegt';
  static const String arabicTranslation = 'مراجعة / نقل التأسيس (التواصل الطبي)';
  static const String ipaTranscription = '[ueberˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2640_ueberlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ueberlegen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التأسيس في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
