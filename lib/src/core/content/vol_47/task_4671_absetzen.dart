// Sovereign Polyglot Core - Task 4671 (Quality Assurance)
class Task4671Engine {
  static const int taskId = 4671;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'absetzen';
  static const String praeteritum = 'setzte ab';
  static const String perfekt = 'hat abgesetzt';
  static const String arabicTranslation = 'فصل / إتمام التنفيذ (ضمان الجودة)';
  static const String ipaTranscription = '[abˈˈzɛtsn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4671_absetzen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess absetzen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التنفيذ في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
