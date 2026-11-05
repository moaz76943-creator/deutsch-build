// Sovereign Linguistic Core - Task 2159
class Task2159Engine {
  static const int taskId = 2159;
  static const String verb = 'zusammenfassen';
  static const String praeteritum = 'fasste zusammen';
  static const String perfekt = 'hat zusammengefasst';
  static const String arabic = 'يلخص';
  static const String ipa = '[tsuˈzamn̩ˌfasn̩]';
  static const String valencyCase = 'Akkusativ';
  static const String cefr = 'B1';
  static const String audioAsset = 'assets/audio/de/task_2159_zusammenfassen.ogg';
  static const String exampleDe = 'Fassen Sie den Text zusammen.';
  static const String exampleAr = 'لخّص التقرير الفني بإيجاز.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'verb': verb, 'praeteritum': praeteritum,
    'perfekt': perfekt, 'arabic': arabic, 'ipa': ipa, 'case': valencyCase,
    'cefr': cefr, 'audio': audioAsset, 'ex_de': exampleDe, 'ex_ar': exampleAr,
  };

  static bool validate() => verb.isNotEmpty && praeteritum.isNotEmpty && perfekt.isNotEmpty;
}
