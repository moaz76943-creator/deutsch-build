// Sovereign Polyglot Core - Task 2695 (Clinical Diagnostics)
class Task2695Engine {
  static const int taskId = 2695;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'einnehmen';
  static const String praeteritum = 'nahm ein';
  static const String perfekt = 'hat eingenommen';
  static const String arabicTranslation = 'إدراج / دمج الاستلام (التواصل الطبي)';
  static const String ipaTranscription = '[einˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2695_einnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung einnehmen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج الاستلام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
