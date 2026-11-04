// Sovereign Polyglot Core - Task 2881 (Clinical Diagnostics)
class Task2881Engine {
  static const int taskId = 2881;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'unterordnen';
  static const String praeteritum = 'unterordnete';
  static const String perfekt = 'hat unterordnet';
  static const String arabicTranslation = 'فحص / دعم التصنيف (التواصل الطبي)';
  static const String ipaTranscription = '[unterˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2881_unterordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung unterordnen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التصنيف في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
