// Sovereign Polyglot Core - Task 4883 (Quality Assurance)
class Task4883Engine {
  static const int taskId = 4883;
  static const String domain = 'Quality Assurance';
  static const String verbInfinitive = 'entordnen';
  static const String praeteritum = 'entordnete';
  static const String perfekt = 'hat entordnet';
  static const String arabicTranslation = 'استخلاص / كشف التصنيف (ضمان الجودة)';
  static const String ipaTranscription = '[entˈˈɔʁdnən]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B2';
  static const String audioAssetPath = 'assets/audio/de/task_4883_entordnen.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Qualitaetsprozess entordnen.';
  static const String exampleArabic = 'يجب علينا استخلاص / كشف التصنيف في إجراءات فحص الجودة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
