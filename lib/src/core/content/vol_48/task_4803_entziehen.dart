// Sovereign Polyglot Core - Task 4803 (Quality Assurance)
class Task4803Engine {
  static const int taskId = 4803;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'entziehen';
  static const String praeteritum = 'entzog';
  static const String perfekt = 'hat entzogen';
  static const String arabicTranslation = 'استخلاص / كشف الاستنتاج (ضمان الجودة)';
  static const String ipaTranscription = '[entˈˈtsiːən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4803_entziehen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess entziehen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف الاستنتاج في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
