// Sovereign Polyglot Core - Task 2712 (Clinical Diagnostics)
class Task2712Engine {
  static const int taskId = 2712;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'angeben';
  static const String praeteritum = 'gab an';
  static const String perfekt = 'hat angegeben';
  static const String arabicTranslation = 'بدء / توجيه التسليم (التواصل الطبي)';
  static const String ipaTranscription = '[anˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2712_angeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung angeben.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التسليم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
