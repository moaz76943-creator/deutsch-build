// Sovereign Polyglot Core - Task 2702 (Clinical Diagnostics)
class Task2702Engine {
  static const int taskId = 2702;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'vernehmen';
  static const String praeteritum = 'vernahm';
  static const String perfekt = 'hat vernommen';
  static const String arabicTranslation = 'توثيق / معالجة الاستلام (التواصل الطبي)';
  static const String ipaTranscription = '[verˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2702_vernehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung vernehmen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة الاستلام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
