// Sovereign Polyglot Core - Task 4778 (Quality Assurance)
class Task4778Engine {
  static const int taskId = 4778;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'vorsprechen';
  static const String praeteritum = 'sprach vor';
  static const String perfekt = 'hat vorgesprochen';
  static const String arabicTranslation = 'تقديم / تحضير التخاطب (ضمان الجودة)';
  static const String ipaTranscription = '[vorˈˈʃpʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4778_vorsprechen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess vorsprechen.';
  static const String exampleArabic = 'يجب علينا تقديم / تحضير التخاطب في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
