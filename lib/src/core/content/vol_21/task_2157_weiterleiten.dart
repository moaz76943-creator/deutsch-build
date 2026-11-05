// Sovereign Linguistic Core - Task 2157
class Task2157Engine {
  static const int taskId = 2157;
  static const String verb = 'weiterleiten';
  static const String praeteritum = 'leitete weiter';
  static const String perfekt = 'hat weitergeleitet';
  static const String arabic = 'يحول / يمرر';
  static const String ipa = '[ˈvaɪ̯tɐˌlaɪ̯tn̩]';
  static const String valencyCase = 'an + Akk';
  static const String cefr = 'B1';
  static const String audioAsset = 'assets/audio/de/task_2157_weiterleiten.ogg';
  static const String exampleDe = 'Ich leite die E-Mail weiter.';
  static const String exampleAr = 'سأقوم بتحويل الرسالة للمختص.';

  static Map<String, dynamic> toDescriptor() => {
    'taskId': taskId, 'verb': verb, 'praeteritum': praeteritum,
    'perfekt': perfekt, 'arabic': arabic, 'ipa': ipa, 'case': valencyCase,
    'cefr': cefr, 'audio': audioAsset, 'ex_de': exampleDe, 'ex_ar': exampleAr,
  };

  static bool validate() => verb.isNotEmpty && praeteritum.isNotEmpty && perfekt.isNotEmpty;
}
