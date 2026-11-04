// Sovereign Polyglot Core - Task 2694 (Clinical Diagnostics)
class Task2694Engine {
  static const int taskId = 2694;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ausnehmen';
  static const String praeteritum = 'nahm aus';
  static const String perfekt = 'hat ausgenommen';
  static const String arabicTranslation = 'توسيع / استخراج الاستلام (التواصل الطبي)';
  static const String ipaTranscription = '[ausˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2694_ausnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ausnehmen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج الاستلام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
