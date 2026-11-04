// Sovereign Polyglot Core - Task 4712 (Quality Assurance)
class Task4712Engine {
  static const int taskId = 4712;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'angeben';
  static const String praeteritum = 'gab an';
  static const String perfekt = 'hat angegeben';
  static const String arabicTranslation = 'بدء / توجيه التسليم (ضمان الجودة)';
  static const String ipaTranscription = '[anˈˈɡeːbn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4712_angeben.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess angeben.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه التسليم في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
