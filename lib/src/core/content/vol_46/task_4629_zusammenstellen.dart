// Sovereign Polyglot Core - Task 4629 (Quality Assurance)
class Task4629Engine {
  static const int taskId = 4629;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'zusammenstellen';
  static const String praeteritum = 'stellte zusammen';
  static const String perfekt = 'hat zusammengestellt';
  static const String arabicTranslation = 'تجميع / توحيد التنظيم (ضمان الجودة)';
  static const String ipaTranscription = '[zusammenˈˈʃtɛlən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4629_zusammenstellen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess zusammenstellen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التنظيم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
