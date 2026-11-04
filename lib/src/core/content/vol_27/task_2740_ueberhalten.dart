// Sovereign Polyglot Core - Task 2740 (Clinical Diagnostics)
class Task2740Engine {
  static const int taskId = 2740;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'ueberhalten';
  static const String praeteritum = 'ueberhielt';
  static const String perfekt = 'hat ueberhalten';
  static const String arabicTranslation = 'مراجعة / نقل الالتزام (التواصل الطبي)';
  static const String ipaTranscription = '[ueberˈˈhaltn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2740_ueberhalten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung ueberhalten.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل الالتزام في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
