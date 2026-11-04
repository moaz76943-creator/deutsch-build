// Sovereign Polyglot Core - Task 4936 (Quality Assurance)
class Task4936Engine {
  static const int taskId = 4936;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'mitbauen';
  static const String praeteritum = 'baute mit';
  static const String perfekt = 'hat mitgebaut';
  static const String arabicTranslation = 'مشاركة / تنسيق التطوير (ضمان الجودة)';
  static const String ipaTranscription = '[mitˈˈbaʊ̯ən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4936_mitbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess mitbauen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التطوير في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
