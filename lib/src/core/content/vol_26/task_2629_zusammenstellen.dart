// Sovereign Polyglot Core - Task 2629 (Clinical Diagnostics)
class Task2629Engine {
  static const int taskId = 2629;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'zusammenstellen';
  static const String praeteritum = 'stellte zusammen';
  static const String perfekt = 'hat zusammengestellt';
  static const String arabicTranslation = 'تجميع / توحيد التنظيم (التواصل الطبي)';
  static const String ipaTranscription = '[zusammenˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2629_zusammenstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung zusammenstellen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التنظيم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
