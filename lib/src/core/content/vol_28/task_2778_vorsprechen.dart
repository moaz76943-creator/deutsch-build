// Sovereign Polyglot Core - Task 2778 (Clinical Diagnostics)
class Task2778Engine {
  static const int taskId = 2778;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'vorsprechen';
  static const String praeteritum = 'sprach vor';
  static const String perfekt = 'hat vorgesprochen';
  static const String arabicTranslation = 'تقديم / تحضير التخاطب (التواصل الطبي)';
  static const String ipaTranscription = '[vorˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2778_vorsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung vorsprechen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التخاطب في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
