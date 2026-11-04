// Sovereign Polyglot Core - Task 2728 (Clinical Diagnostics)
class Task2728Engine {
  static const int taskId = 2728;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'weitergeben';
  static const String praeteritum = 'gab weiter';
  static const String perfekt = 'hat weitergegeben';
  static const String arabicTranslation = 'مواصلة / تمرير التسليم (التواصل الطبي)';
  static const String ipaTranscription = '[weiterˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2728_weitergeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung weitergeben.';
  static const String exampleArabic = 'يجب علينا مواصلة / تمرير التسليم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
