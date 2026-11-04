// Sovereign Polyglot Core - Task 4786 (Quality Assurance)
class Task4786Engine {
  static const int taskId = 4786;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'durchsprechen';
  static const String praeteritum = 'sprach durch';
  static const String perfekt = 'hat durchgesprochen';
  static const String arabicTranslation = 'إتمام شامل التخاطب (ضمان الجودة)';
  static const String ipaTranscription = '[durchˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4786_durchsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess durchsprechen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل التخاطب في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
