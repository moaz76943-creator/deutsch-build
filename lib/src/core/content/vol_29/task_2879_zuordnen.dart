// Sovereign Polyglot Core - Task 2879 (Clinical Diagnostics)
class Task2879Engine {
  static const int taskId = 2879;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'zuordnen';
  static const String praeteritum = 'ordnete zu';
  static const String perfekt = 'hat zugeordnet';
  static const String arabicTranslation = 'توجيه / إغلاق التصنيف (التواصل الطبي)';
  static const String ipaTranscription = '[zuˈˈɔʁdnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2879_zuordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung zuordnen.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق التصنيف في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
