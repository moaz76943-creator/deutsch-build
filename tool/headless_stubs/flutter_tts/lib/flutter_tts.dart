final class FlutterTts {
  FlutterTts();

  Future<dynamic> get getVoices async => const <Object?>[];

  Future<bool> isLanguageInstalled(String language) async => false;

  Future<dynamic> stop() async => 1;

  Future<dynamic> pause() async => 1;

  Future<dynamic> setVoice(Map<String, String> voice) async => 1;

  Future<dynamic> setLanguage(String language) async => 1;

  Future<dynamic> setSpeechRate(double rate) async => 1;

  Future<dynamic> setPitch(double pitch) async => 1;

  Future<dynamic> setVolume(double volume) async => 1;

  Future<dynamic> awaitSpeakCompletion(bool enabled) async => 1;

  Future<dynamic> speak(String text) async => 0;
}
