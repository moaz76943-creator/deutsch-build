// Sovereign Polyglot Core - Task 2771 (Clinical Diagnostics)
class Task2771Engine {
  static const int taskId = 2771;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'absprechen';
  static const String praeteritum = 'sprach ab';
  static const String perfekt = 'hat abgesprochen';
  static const String arabicTranslation = 'فصل / إتمام التخاطب (التواصل الطبي)';
  static const String ipaTranscription = '[abˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2771_absprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung absprechen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التخاطب في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
