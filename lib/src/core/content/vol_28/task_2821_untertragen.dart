// Sovereign Polyglot Core - Task 2821 (Clinical Diagnostics)
class Task2821Engine {
  static const int taskId = 2821;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'untertragen';
  static const String praeteritum = 'untertrug';
  static const String perfekt = 'hat untertragen';
  static const String arabicTranslation = 'فحص / دعم المسؤولية (التواصل الطبي)';
  static const String ipaTranscription = '[unterˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2821_untertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung untertragen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم المسؤولية في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
