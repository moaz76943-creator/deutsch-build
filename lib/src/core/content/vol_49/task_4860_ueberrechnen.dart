// Sovereign Polyglot Core - Task 4860 (Quality Assurance)
class Task4860Engine {
  static const int taskId = 4860;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'ueberrechnen';
  static const String praeteritum = 'ueberrechnete';
  static const String perfekt = 'hat ueberrechnet';
  static const String arabicTranslation = 'مراجعة / نقل التقدير (ضمان الجودة)';
  static const String ipaTranscription = '[ueberˈˈʁɛçnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4860_ueberrechnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess ueberrechnen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التقدير في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
