// Sovereign Polyglot Core - Task 4823 (Quality Assurance)
class Task4823Engine {
  static const int taskId = 4823;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'enttragen';
  static const String praeteritum = 'enttrug';
  static const String perfekt = 'hat enttragen';
  static const String arabicTranslation = 'استخلاص / كشف المسؤولية (ضمان الجودة)';
  static const String ipaTranscription = '[entˈˈtʁaːɡn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4823_enttragen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess enttragen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف المسؤولية في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
