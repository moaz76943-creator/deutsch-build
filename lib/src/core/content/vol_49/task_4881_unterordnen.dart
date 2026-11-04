// Sovereign Polyglot Core - Task 4881 (Quality Assurance)
class Task4881Engine {
  static const int taskId = 4881;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'unterordnen';
  static const String praeteritum = 'unterordnete';
  static const String perfekt = 'hat unterordnet';
  static const String arabicTranslation = 'فحص / دعم التصنيف (ضمان الجودة)';
  static const String ipaTranscription = '[unterˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4881_unterordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess unterordnen.';
  static const String exampleArabic = 'يجب علينا فحص / دعم التصنيف في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
