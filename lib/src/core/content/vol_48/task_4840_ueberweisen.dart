// Sovereign Polyglot Core - Task 4840 (Quality Assurance)
class Task4840Engine {
  static const int taskId = 4840;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'ueberweisen';
  static const String praeteritum = 'ueberwies';
  static const String perfekt = 'hat ueberwiesen';
  static const String arabicTranslation = 'مراجعة / نقل التوجيه (ضمان الجودة)';
  static const String ipaTranscription = '[ueberˈˈvaɪ̯zn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4840_ueberweisen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess ueberweisen.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل التوجيه في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
