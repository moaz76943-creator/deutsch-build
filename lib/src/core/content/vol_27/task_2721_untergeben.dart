// Sovereign Polyglot Core - Task 2721 (Clinical Diagnostics)
class Task2721Engine {
  static const int taskId = 2721;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'untergeben';
  static const String praeteritum = 'untergab';
  static const String perfekt = 'hat untergeben';
  static const String arabicTranslation = 'فحص / دعم التسليم (التواصل الطبي)';
  static const String ipaTranscription = '[unterˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2721_untergeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung untergeben.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التسليم في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
