// Sovereign Polyglot Core - Task 2625 (Clinical Diagnostics)
class Task2625Engine {
  static const int taskId = 2625;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'erstellen';
  static const String praeteritum = 'erstellte';
  static const String perfekt = 'hat erstellt';
  static const String arabicTranslation = 'إنجاز / تحقيق التنظيم (التواصل الطبي)';
  static const String ipaTranscription = '[erˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2625_erstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung erstellen.';
  static const String exampleArabic = 'يجب علينا إنجاز / تحقيق التنظيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
