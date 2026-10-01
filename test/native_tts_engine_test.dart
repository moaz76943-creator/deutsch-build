import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:deutsch_bilarabi/features/audio/data/native_tts_engine.dart';
import 'package:deutsch_bilarabi/features/audio/domain/entities/audio_playback_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('NativeTtsEngine initialization', () {
    final engine = NativeTtsEngine();
    expect(engine, isNotNull);
    engine.dispose();
  });
}
