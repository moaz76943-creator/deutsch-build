// Sovereign Polyglot Core - Task 4576 (Quality Assurance)
class Task4576Engine {
  static const int taskId = 4576;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'mitplanen';
  static const String praeteritum = 'plante mit';
  static const String perfekt = 'hat mitgeplant';
  static const String arabicTranslation = 'مشاركة / تنسيق التخطيط (ضمان الجودة)';
  static const String ipaTranscription = '[mitˈˈplaːnən]';
  static const String valencyCase = 'Dativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4576_mitplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess mitplanen.';
  static const String exampleArabic = 'يجب علينا مشاركة / تنسيق التخطيط في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
