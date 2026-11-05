// Sovereign Linguistic Core - Task 2151
class Task2151Engine {
  static const int taskId = 2151;
  static const String verb = 'unterbrechen';
  static const String praeteritum = 'unterbrach';
  static const String perfekt = 'hat unterbrochen';
  static const String arabic = 'يقاطع / يعلق';
  static const String ipa = '[ʔʊntɐˈbʁɛçn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefr = 'B2';
  static const String audioAsset = 'assets/audio/de/task_2151_unterbrechen.ogg';
  static const String exampleDe = 'Darf ich Sie kurz unterbrechen?';
  static const String exampleAr = 'هل تسمح لي بمقاطعتك لبرهة؟';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'verb': verb, 'praeteritum': praeteritum,
    'perfekt': perfekt, 'arabic': arabic, 'ipa': ipa, 'case': valencyCase,
    'cefr': cefr, 'audio': audioAsset, 'ex_de': exampleDe, 'ex_ar': exampleAr,
  };

  static bool validate() => verb.isNotEmpty && praeteritum.isNotEmpty && perfekt.isNotEmpty;
}
