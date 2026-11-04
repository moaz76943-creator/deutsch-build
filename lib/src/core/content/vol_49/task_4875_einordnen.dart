// Sovereign Polyglot Core - Task 4875 (Quality Assurance)
class Task4875Engine {
  static const int taskId = 4875;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'einordnen';
  static const String praeteritum = 'ordnete ein';
  static const String perfekt = 'hat eingeordnet';
  static const String arabicTranslation = 'إدراج / دمج التصنيف (ضمان الجودة)';
  static const String ipaTranscription = '[einˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4875_einordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess einordnen.';
  static const String exampleArabic = 'يجب علينا إدراج / دمج التصنيف في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
