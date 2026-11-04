// Sovereign Polyglot Core - Task 2874 (Clinical Diagnostics)
class Task2874Engine {
  static const int taskId = 2874;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ausordnen';
  static const String praeteritum = 'ordnete aus';
  static const String perfekt = 'hat ausgeordnet';
  static const String arabicTranslation = 'توسيع / استخراج التصنيف (التواصل الطبي)';
  static const String ipaTranscription = '[ausˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2874_ausordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ausordnen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج التصنيف في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
