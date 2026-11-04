// Sovereign Polyglot Core - Task 2840 (Clinical Diagnostics)
class Task2840Engine {
  static const int taskId = 2840;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ueberweisen';
  static const String praeteritum = 'ueberwies';
  static const String perfekt = 'hat ueberwiesen';
  static const String arabicTranslation = 'مراجعة / نقل التوجيه (التواصل الطبي)';
  static const String ipaTranscription = '[ueberˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2840_ueberweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ueberweisen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التوجيه في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
