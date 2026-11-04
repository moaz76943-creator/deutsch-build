// Sovereign Polyglot Core - Task 2820 (Clinical Diagnostics)
class Task2820Engine {
  static const int taskId = 2820;
  static const String domain = 'Clinical Diagnostics';
  static const String verbInfinitive = 'uebertragen';
  static const String praeteritum = 'uebertrug';
  static const String perfekt = 'hat uebertragen';
  static const String arabicTranslation = 'مراجعة / نقل المسؤولية (التواصل الطبي)';
  static const String ipaTranscription = '[ueberˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2820_uebertragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess in der Fachabteilung uebertragen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل المسؤولية في القسم الطبي المتخصص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
