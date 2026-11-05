// Sovereign Linguistic Core - Task 2154
class Task2154Engine {
  static const int taskId = 2154;
  static const String verb = 'entscheiden';
  static const String praeteritum = 'entschied';
  static const String perfekt = 'hat entschieden';
  static const String arabic = 'يقرر / يحسم';
  static const String ipa = '[ʔɛntˈʃaɪ̯dn̩]';
  static const String valencyCase = 'über + Akk';
  static const String cefr = 'B1';
  static const String audioAsset = 'assets/audio/de/task_2154_entscheiden.ogg';
  static const String exampleDe = 'Die Jury hat entschieden.';
  static const String exampleAr = 'حسمت لجنة التحكيم القرار النهائي.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'verb': verb, 'praeteritum': praeteritum,
    'perfekt': perfekt, 'arabic': arabic, 'ipa': ipa, 'case': valencyCase,
    'cefr': cefr, 'audio': audioAsset, 'ex_de': exampleDe, 'ex_ar': exampleAr,
  };

  static bool validate() => verb.isNotEmpty && praeteritum.isNotEmpty && perfekt.isNotEmpty;
}
