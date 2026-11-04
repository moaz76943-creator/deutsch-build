// Sovereign Polyglot Core - Task 2580 (Clinical Diagnostics)
class Task2580Engine {
  static const int taskId = 2580;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ueberplanen';
  static const String praeteritum = 'ueberplante';
  static const String perfekt = 'hat ueberplant';
  static const String arabicTranslation = 'مراجعة / نقل التخطيط (التواصل الطبي)';
  static const String ipaTranscription = '[ueberˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2580_ueberplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ueberplanen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التخطيط في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
