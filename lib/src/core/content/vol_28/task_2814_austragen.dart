// Sovereign Polyglot Core - Task 2814 (Clinical Diagnostics)
class Task2814Engine {
  static const int taskId = 2814;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'austragen';
  static const String praeteritum = 'trug aus';
  static const String perfekt = 'hat ausgetragen';
  static const String arabicTranslation = 'توسيع / استخراج المسؤولية (التواصل الطبي)';
  static const String ipaTranscription = '[ausˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2814_austragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung austragen.';
  static const String exampleArabic = 'يجب علينا توسيع / استخراج المسؤولية في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
