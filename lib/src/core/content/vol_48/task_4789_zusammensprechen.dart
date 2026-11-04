// Sovereign Polyglot Core - Task 4789 (Quality Assurance)
class Task4789Engine {
  static const int taskId = 4789;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'zusammensprechen';
  static const String praeteritum = 'sprach zusammen';
  static const String perfekt = 'hat zusammengesprochen';
  static const String arabicTranslation = 'تجميع / توحيد التخاطب (ضمان الجودة)';
  static const String ipaTranscription = '[zusammenˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4789_zusammensprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess zusammensprechen.';
  static const String exampleArabic = 'يجب علينا تجميع / توحيد التخاطب في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
