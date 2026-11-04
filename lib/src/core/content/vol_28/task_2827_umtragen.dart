// Sovereign Polyglot Core - Task 2827 (Clinical Diagnostics)
class Task2827Engine {
  static const int taskId = 2827;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'umtragen';
  static const String praeteritum = 'trug um';
  static const String perfekt = 'hat umgetragen';
  static const String arabicTranslation = 'إعادة هيكلة المسؤولية (التواصل الطبي)';
  static const String ipaTranscription = '[umˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2827_umtragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung umtragen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة المسؤولية في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
