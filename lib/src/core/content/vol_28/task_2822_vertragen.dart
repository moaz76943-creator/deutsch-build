// Sovereign Polyglot Core - Task 2822 (Clinical Diagnostics)
class Task2822Engine {
  static const int taskId = 2822;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'vertragen';
  static const String praeteritum = 'vertrug';
  static const String perfekt = 'hat vertragen';
  static const String arabicTranslation = 'توثيق / معالجة المسؤولية (التواصل الطبي)';
  static const String ipaTranscription = '[verˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2822_vertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung vertragen.';
  static const String exampleArabic = 'يجب علينا توثيق / معالجة المسؤولية في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
