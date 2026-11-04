// Sovereign Polyglot Core - Task 2659 (Clinical Diagnostics)
class Task2659Engine {
  static const int taskId = 2659;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'zufuehren';
  static const String praeteritum = 'fuehrte zu';
  static const String perfekt = 'hat zugefuehrt';
  static const String arabicTranslation = 'توجيه / إغلاق الإدارة (التواصل الطبي)';
  static const String ipaTranscription = '[zuˈˈfyːʁən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2659_zufuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung zufuehren.';
  static const String exampleArabic = 'يجب علينا توجيه / إغلاق الإدارة في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
