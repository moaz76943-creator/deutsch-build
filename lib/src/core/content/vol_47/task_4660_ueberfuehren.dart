// Sovereign Polyglot Core - Task 4660 (Quality Assurance)
class Task4660Engine {
  static const int taskId = 4660;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'ueberfuehren';
  static const String praeteritum = 'ueberfuehrte';
  static const String perfekt = 'hat ueberfuehrt';
  static const String arabicTranslation = 'مراجعة / نقل الإدارة (ضمان الجودة)';
  static const String ipaTranscription = '[ueberˈˈfyːʁən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4660_ueberfuehren.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess ueberfuehren.';
  static const String exampleArabic = 'يجب علينا مراجعة / نقل الإدارة في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
