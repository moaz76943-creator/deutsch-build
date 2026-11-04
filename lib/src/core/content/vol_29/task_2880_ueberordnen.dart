// Sovereign Polyglot Core - Task 2880 (Clinical Diagnostics)
class Task2880Engine {
  static const int taskId = 2880;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ueberordnen';
  static const String praeteritum = 'ueberordnete';
  static const String perfekt = 'hat ueberordnet';
  static const String arabicTranslation = 'مراجعة / نقل التصنيف (التواصل الطبي)';
  static const String ipaTranscription = '[ueberˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2880_ueberordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ueberordnen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التصنيف في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
