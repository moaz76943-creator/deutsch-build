// Sovereign Polyglot Core - Task 2884 (Clinical Diagnostics)
class Task2884Engine {
  static const int taskId = 2884;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'beordnen';
  static const String praeteritum = 'beordnete';
  static const String perfekt = 'hat beordnet';
  static const String arabicTranslation = 'تأكيد / تزويد التصنيف (التواصل الطبي)';
  static const String ipaTranscription = '[beˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2884_beordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung beordnen.';
  static const String exampleArabic = 'يجب علينا تأكيد / تزويد التصنيف في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
