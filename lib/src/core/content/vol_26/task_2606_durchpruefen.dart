// Sovereign Polyglot Core - Task 2606 (Clinical Diagnostics)
class Task2606Engine {
  static const int taskId = 2606;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'durchpruefen';
  static const String praeteritum = 'pruefte durch';
  static const String perfekt = 'hat durchgeprueft';
  static const String arabicTranslation = 'إتمام شامل التدقيق (التواصل الطبي)';
  static const String ipaTranscription = '[durchˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2606_durchpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung durchpruefen.';
  static const String exampleArabic = 'يجب علينا إتمام شامل التدقيق في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
