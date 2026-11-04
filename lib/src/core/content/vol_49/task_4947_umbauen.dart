// Sovereign Polyglot Core - Task 4947 (Quality Assurance)
class Task4947Engine {
  static const int taskId = 4947;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'umbauen';
  static const String praeteritum = 'baute um';
  static const String perfekt = 'hat umgebaut';
  static const String arabicTranslation = 'إعادة هيكلة التطوير (ضمان الجودة)';
  static const String ipaTranscription = '[umˈˈbaʊ̯ən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4947_umbauen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess umbauen.';
  static const String exampleArabic = 'يجب علينا إعادة هيكلة التطوير في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
