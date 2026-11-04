// Sovereign Polyglot Core - Task 2878 (Clinical Diagnostics)
class Task2878Engine {
  static const int taskId = 2878;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'vorordnen';
  static const String praeteritum = 'ordnete vor';
  static const String perfekt = 'hat vorgeordnet';
  static const String arabicTranslation = 'تقديم / تحضير التصنيف (التواصل الطبي)';
  static const String ipaTranscription = '[vorˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2878_vorordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung vorordnen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التصنيف في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
