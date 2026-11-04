// Sovereign Polyglot Core - Task 2861 (Clinical Diagnostics)
class Task2861Engine {
  static const int taskId = 2861;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'unterrechnen';
  static const String praeteritum = 'unterrechnete';
  static const String perfekt = 'hat unterrechnet';
  static const String arabicTranslation = 'فحص / دعم التقدير (التواصل الطبي)';
  static const String ipaTranscription = '[unterˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2861_unterrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung unterrechnen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التقدير في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
