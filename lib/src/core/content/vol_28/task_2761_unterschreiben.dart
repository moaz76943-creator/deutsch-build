// Sovereign Polyglot Core - Task 2761 (Clinical Diagnostics)
class Task2761Engine {
  static const int taskId = 2761;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'unterschreiben';
  static const String praeteritum = 'unterschrieb';
  static const String perfekt = 'hat unterschrieben';
  static const String arabicTranslation = 'فحص / دعم التدوين (التواصل الطبي)';
  static const String ipaTranscription = '[unterˈˈʃʁaɪ̯bn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2761_unterschreiben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung unterschreiben.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التدوين في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
