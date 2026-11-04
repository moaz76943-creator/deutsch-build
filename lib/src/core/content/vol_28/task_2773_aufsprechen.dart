// Sovereign Polyglot Core - Task 2773 (Clinical Diagnostics)
class Task2773Engine {
  static const int taskId = 2773;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'aufsprechen';
  static const String praeteritum = 'sprach auf';
  static const String perfekt = 'hat aufgesprochen';
  static const String arabicTranslation = 'رفع / فتح التخاطب (التواصل الطبي)';
  static const String ipaTranscription = '[aufˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2773_aufsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung aufsprechen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التخاطب في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
