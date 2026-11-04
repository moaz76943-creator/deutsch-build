// Sovereign Polyglot Core - Task 2655 (Clinical Diagnostics)
class Task2655Engine {
  static const int taskId = 2655;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'einfuehren';
  static const String praeteritum = 'fuehrte ein';
  static const String perfekt = 'hat eingefuehrt';
  static const String arabicTranslation = 'إدراج / دمج الإدارة (التواصل الطبي)';
  static const String ipaTranscription = '[einˈˈfyːʁən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2655_einfuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung einfuehren.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج الإدارة في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
