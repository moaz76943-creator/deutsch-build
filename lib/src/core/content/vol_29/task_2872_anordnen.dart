// Sovereign Polyglot Core - Task 2872 (Clinical Diagnostics)
class Task2872Engine {
  static const int taskId = 2872;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'anordnen';
  static const String praeteritum = 'ordnete an';
  static const String perfekt = 'hat angeordnet';
  static const String arabicTranslation = 'بدء / توجيه التصنيف (التواصل الطبي)';
  static const String ipaTranscription = '[anˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2872_anordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung anordnen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التصنيف في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
