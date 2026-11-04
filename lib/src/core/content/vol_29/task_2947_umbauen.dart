// Sovereign Polyglot Core - Task 2947 (Clinical Diagnostics)
class Task2947Engine {
  static const int taskId = 2947;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'umbauen';
  static const String praeteritum = 'baute um';
  static const String perfekt = 'hat umgebaut';
  static const String arabicTranslation = 'إعادة هيكلة التطوير (التواصل الطبي)';
  static const String ipaTranscription = '[umˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2947_umbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung umbauen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التطوير في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
