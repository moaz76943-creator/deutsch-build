// Sovereign Polyglot Core - Task 2660 (Clinical Diagnostics)
class Task2660Engine {
  static const int taskId = 2660;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ueberfuehren';
  static const String praeteritum = 'ueberfuehrte';
  static const String perfekt = 'hat ueberfuehrt';
  static const String arabicTranslation = 'مراجعة / نقل الإدارة (التواصل الطبي)';
  static const String ipaTranscription = '[ueberˈˈfyːʁən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2660_ueberfuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ueberfuehren.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل الإدارة في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
