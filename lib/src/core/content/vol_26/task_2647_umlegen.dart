// Sovereign Polyglot Core - Task 2647 (Clinical Diagnostics)
class Task2647Engine {
  static const int taskId = 2647;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'umlegen';
  static const String praeteritum = 'legte um';
  static const String perfekt = 'hat umgelegt';
  static const String arabicTranslation = 'إعادة هيكلة التأسيس (التواصل الطبي)';
  static const String ipaTranscription = '[umˈˈleːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2647_umlegen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung umlegen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التأسيس في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
