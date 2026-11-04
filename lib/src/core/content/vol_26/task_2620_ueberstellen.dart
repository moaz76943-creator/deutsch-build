// Sovereign Polyglot Core - Task 2620 (Clinical Diagnostics)
class Task2620Engine {
  static const int taskId = 2620;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ueberstellen';
  static const String praeteritum = 'ueberstellte';
  static const String perfekt = 'hat ueberstellt';
  static const String arabicTranslation = 'مراجعة / نقل التنظيم (التواصل الطبي)';
  static const String ipaTranscription = '[ueberˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2620_ueberstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ueberstellen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التنظيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
