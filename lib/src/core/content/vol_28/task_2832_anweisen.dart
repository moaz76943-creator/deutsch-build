// Sovereign Polyglot Core - Task 2832 (Clinical Diagnostics)
class Task2832Engine {
  static const int taskId = 2832;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'anweisen';
  static const String praeteritum = 'wies an';
  static const String perfekt = 'hat angewiesen';
  static const String arabicTranslation = 'بدء / توجيه التوجيه (التواصل الطبي)';
  static const String ipaTranscription = '[anˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2832_anweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung anweisen.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التوجيه في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
