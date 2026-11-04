// Sovereign Polyglot Core - Task 2671 (Clinical Diagnostics)
class Task2671Engine {
  static const int taskId = 2671;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'absetzen';
  static const String praeteritum = 'setzte ab';
  static const String perfekt = 'hat abgesetzt';
  static const String arabicTranslation = 'فصل / إتمام التنفيذ (التواصل الطبي)';
  static const String ipaTranscription = '[abˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2671_absetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung absetzen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التنفيذ في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
