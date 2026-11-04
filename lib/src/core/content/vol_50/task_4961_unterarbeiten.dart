// Sovereign Polyglot Core - Task 4961 (Civil Infrastructure)
class Task4961Engine {
  static const int taskId = 4961;
  static const String domain = 'Civil Infrastructure';
  static const String verbInfinitive = 'unterarbeiten';
  static const String praeteritum = 'unterarbeitete';
  static const String perfekt = 'hat unterarbeitet';
  static const String arabicTranslation = 'فحص / دعم العمل (الهندسة المدنية)';
  static const String ipaTranscription = '[unterˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'B1';
  static const String audioAssetPath = 'assets/audio/de/task_4961_unterarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess auf der Projektbaustelle unterarbeiten.';
  static const String exampleArabic = 'يجب علينا فحص / دعم العمل في موقع المشروع الهندسي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
