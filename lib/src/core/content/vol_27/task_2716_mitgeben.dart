// Sovereign Polyglot Core - Task 2716 (Clinical Diagnostics)
class Task2716Engine {
  static const int taskId = 2716;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'mitgeben';
  static const String praeteritum = 'gab mit';
  static const String perfekt = 'hat mitgegeben';
  static const String arabicTranslation = 'مشاركة / تنسيق التسليم (التواصل الطبي)';
  static const String ipaTranscription = '[mitˈˈɡeːbn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2716_mitgeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung mitgeben.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التسليم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
