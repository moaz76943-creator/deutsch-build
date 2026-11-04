// Sovereign Polyglot Core - Task 2581 (Clinical Diagnostics)
class Task2581Engine {
  static const int taskId = 2581;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'unterplanen';
  static const String praeteritum = 'unterplante';
  static const String perfekt = 'hat unterplant';
  static const String arabicTranslation = 'فحص / دعم التخطيط (التواصل الطبي)';
  static const String ipaTranscription = '[unterˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2581_unterplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung unterplanen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التخطيط في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
