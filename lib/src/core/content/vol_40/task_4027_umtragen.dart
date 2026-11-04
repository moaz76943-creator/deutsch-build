// Sovereign Polyglot Core - Task 4027 (Financial Auditing)
class Task4027Engine {
  static const int taskId = 4027;
  static const String domain = 'Financial Auditing';
  static const String verbInfinitive = 'umtragen';
  static const String praeteritum = 'trug um';
  static const String perfekt = 'hat umgetragen';
  static const String arabicTranslation = 'إعادة هيكلة المسؤولية (التدقيق المالي)';
  static const String ipaTranscription = '[umˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_4027_umtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Quartalsabrechnung umtragen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة المسؤولية في التسوية المالية الفصلية.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
