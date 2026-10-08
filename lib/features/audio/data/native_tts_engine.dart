import '../../../../services/tts_service.dart';

class NativeTtsEngine {
  final FlutterOfflineTtsEngine _engine = FlutterOfflineTtsEngine();

  Future<void> speak(String text, {String lang = 'de-DE'}) async {
    await _engine.speak(text, lang: lang);
  }

  Future<void> stop() async {
    await _engine.stop();
  }
}
