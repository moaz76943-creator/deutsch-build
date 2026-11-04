// Sovereign Polyglot Core - Task 2786 (Clinical Diagnostics)
class Task2786Engine {
  static const int taskId = 2786;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'durchsprechen';
  static const String praeteritum = 'sprach durch';
  static const String perfekt = 'hat durchgesprochen';
  static const String arabicTranslation = 'إتمام شامل التخاطب (التواصل الطبي)';
  static const String ipaTranscription = '[durchˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2786_durchsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung durchsprechen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل التخاطب في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
