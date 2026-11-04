// Sovereign Polyglot Core - Task 2571 (Clinical Diagnostics)
class Task2571Engine {
  static const int taskId = 2571;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'abplanen';
  static const String praeteritum = 'plante ab';
  static const String perfekt = 'hat abgeplant';
  static const String arabicTranslation = 'فصل / إتمام التخطيط (التواصل الطبي)';
  static const String ipaTranscription = '[abˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2571_abplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung abplanen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التخطيط في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
