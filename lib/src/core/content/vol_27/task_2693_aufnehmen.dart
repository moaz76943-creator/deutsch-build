// Sovereign Polyglot Core - Task 2693 (Clinical Diagnostics)
class Task2693Engine {
  static const int taskId = 2693;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'aufnehmen';
  static const String praeteritum = 'nahm auf';
  static const String perfekt = 'hat aufgenommen';
  static const String arabicTranslation = 'رفع / فتح الاستلام (التواصل الطبي)';
  static const String ipaTranscription = '[aufˈˈneːmən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2693_aufnehmen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung aufnehmen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح الاستلام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
