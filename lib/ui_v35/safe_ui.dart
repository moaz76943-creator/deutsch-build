/// Backward-compatible UI import surface for text-to-speech helpers.
///
/// The actual flutter_tts dependency is isolated in TtsService. Existing UI
/// imports can remain stable while the package boundary stays in services/.
export '../services/tts_service.dart';
export '../services/safe_tts_controller.dart';
export 'shared/article_badge.dart';
export 'widgets/vocabulary_visuals.dart';

import '../services/safe_tts_controller.dart';

Future<void> safeSpeak(
  SafeTtsController tts,
  String text, {
  double rate = .46,
}) =>
    tts.speak(text, rate: rate);

Future<void> safeTtsStop(SafeTtsController tts) => tts.stop();

Future<void> safeTtsShutdown(SafeTtsController tts) => tts.shutdown();
