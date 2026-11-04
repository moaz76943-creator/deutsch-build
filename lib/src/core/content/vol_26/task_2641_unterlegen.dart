// Sovereign Polyglot Core - Task 2641 (Clinical Diagnostics)
class Task2641Engine {
  static const int taskId = 2641;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'unterlegen';
  static const String praeteritum = 'unterlegte';
  static const String perfekt = 'hat unterlegt';
  static const String arabicTranslation = 'فحص / دعم التأسيس (التواصل الطبي)';
  static const String ipaTranscription = '[unterˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2641_unterlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung unterlegen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التأسيس في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
