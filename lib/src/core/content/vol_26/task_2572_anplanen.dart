// Sovereign Polyglot Core - Task 2572 (Clinical Diagnostics)
class Task2572Engine {
  static const int taskId = 2572;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'anplanen';
  static const String praeteritum = 'plante an';
  static const String perfekt = 'hat angeplant';
  static const String arabicTranslation = 'بدء / توجيه التخطيط (التواصل الطبي)';
  static const String ipaTranscription = '[anˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2572_anplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung anplanen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التخطيط في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
