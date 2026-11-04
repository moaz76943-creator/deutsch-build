// Sovereign Polyglot Core - Task 4583 (Quality Assurance)
class Task4583Engine {
  static const int taskId = 4583;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'entplanen';
  static const String praeteritum = 'entplante';
  static const String perfekt = 'hat entplant';
  static const String arabicTranslation = 'استخلاص / كشف التخطيط (ضمان الجودة)';
  static const String ipaTranscription = '[entˈˈplaːnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4583_entplanen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess entplanen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التخطيط في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
