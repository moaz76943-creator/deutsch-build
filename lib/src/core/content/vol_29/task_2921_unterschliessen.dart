// Sovereign Polyglot Core - Task 2921 (Clinical Diagnostics)
class Task2921Engine {
  static const int taskId = 2921;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'unterschliessen';
  static const String praeteritum = 'unterschloss';
  static const String perfekt = 'hat unterschlossen';
  static const String arabicTranslation = 'فحص / دعم الإبرام (التواصل الطبي)';
  static const String ipaTranscription = '[unterˈˈʃliːsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2921_unterschliessen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung unterschliessen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم الإبرام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
