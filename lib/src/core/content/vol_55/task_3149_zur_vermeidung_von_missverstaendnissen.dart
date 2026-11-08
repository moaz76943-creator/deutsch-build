// Sovereign Diplomatic Syntax Core - Task 3149
class Task3149Engine {
  static const int taskId = 3149;
  static const String identifier = 'zur_vermeidung_von_missverstaendnissen';
  static const String diplomaticPhrase = 'zur Vermeidung von Missverständnissen';
  static const String arabicMeaning = 'تفادياً لأي التباس أو تأويل غير دقيق للمواصفة';
  static const String cefrLevel = 'B1';
  static const String functionalCategory = 'Klärende Präzisierung';
  static const String audioAssetPath = 'assets/audio/diplomatic/task_3149_zur_vermeidung_von_missverstaendnissen.ogg';
  static const String exampleGerman = 'Zur Vermeidung von Missverständnissen definieren wir Typen strikt.';
  static const String exampleArabic = 'تفادياً للالتباس، نحدد الأنواع البرمجية بصرامة.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'id': identifier, 'phrase': diplomaticPhrase,
    'arabic': arabicMeaning, 'cefr': cefrLevel, 'category': functionalCategory,
    'audio': audioAssetPath, 'ex_de': exampleGerman, 'ex_ar': exampleArabic,
  };

  static bool validate() => diplomaticPhrase.isNotEmpty && audioAssetPath.endsWith('.ogg');
}
