// Sovereign Polyglot Core - Task 2707 (Clinical Diagnostics)
class Task2707Engine {
  static const int taskId = 2707;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'umnehmen';
  static const String praeteritum = 'nahm um';
  static const String perfekt = 'hat umgenommen';
  static const String arabicTranslation = 'إعادة هيكلة الاستلام (التواصل الطبي)';
  static const String ipaTranscription = '[umˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2707_umnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung umnehmen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة الاستلام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
