// Sovereign Polyglot Core - Task 4593 (Quality Assurance)
class Task4593Engine {
  static const int taskId = 4593;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'aufpruefen';
  static const String praeteritum = 'pruefte auf';
  static const String perfekt = 'hat aufgeprueft';
  static const String arabicTranslation = 'رفع / فتح التدقيق (ضمان الجودة)';
  static const String ipaTranscription = '[aufˈˈpʁyːfn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4593_aufpruefen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess aufpruefen.';
  static const String exampleArabic = 'يجب علينا رفع / فتح التدقيق في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
