// Sovereign Polyglot Core - Task 2952 (Academic Research)
class Task2952Engine {
  static const int taskId = 2952;
  static const String domain = 'Academic Research';
  static const String verbInfinitive = 'anarbeiten';
  static const String praeteritum = 'arbeitete an';
  static const String perfekt = 'hat angearbeitet';
  static const String arabicTranslation = 'بدء / توجيه العمل (البحث الأكاديمي)';
  static const String ipaTranscription = '[anˈˈaʁbaɪ̯tn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefrLevel = 'C1';
  static const String audioAssetPath = 'assets/audio/de/task_2952_anarbeiten.ogg';
  static const String exampleGerman = 'Wir muessen den Prozess im Forschungsprojekt anarbeiten.';
  static const String exampleArabic = 'يجب علينا بدء / توجيه العمل في المشروع البحثي الجامعي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'domain': domain, 'verb': verbInfinitive,
    'praeteritum': praeteritum, 'perfekt': perfekt, 'arabic': arabicTranslation,
    'ipa': ipaTranscription, 'case': valencyCase, 'cefr': cefrLevel,
    'audio': audioAssetPath, 'example_de': exampleGerman, 'example_ar': exampleArabic
  };

  static bool validateSyntax() => verbInfinitive.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
