// Sovereign Polyglot Core - Task 2841 (Clinical Diagnostics)
class Task2841Engine {
  static const int taskId = 2841;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'unterweisen';
  static const String praeteritum = 'unterwies';
  static const String perfekt = 'hat unterwiesen';
  static const String arabicTranslation = 'فحص / دعم التوجيه (التواصل الطبي)';
  static const String ipaTranscription = '[unterˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2841_unterweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung unterweisen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التوجيه في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
