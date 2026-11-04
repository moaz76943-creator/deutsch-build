// Sovereign Polyglot Core - Task 4816 (Quality Assurance)
class Task4816Engine {
  static const int taskId = 4816;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'mittragen';
  static const String praeteritum = 'trug mit';
  static const String perfekt = 'hat mitgetragen';
  static const String arabicTranslation = 'مشاركة / تنسيق المسؤولية (ضمان الجودة)';
  static const String ipaTranscription = '[mitˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4816_mittragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess mittragen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق المسؤولية في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
