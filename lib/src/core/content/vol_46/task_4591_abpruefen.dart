// Sovereign Polyglot Core - Task 4591 (Quality Assurance)
class Task4591Engine {
  static const int taskId = 4591;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'abpruefen';
  static const String praeteritum = 'pruefte ab';
  static const String perfekt = 'hat abgeprueft';
  static const String arabicTranslation = 'فصل / إتمام التدقيق (ضمان الجودة)';
  static const String ipaTranscription = '[abˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4591_abpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess abpruefen.';
  static const String exampleArabic = 'يجب علينا فصل / إتمام التدقيق في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
