import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/audio/data/native_tts_engine.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('NativeTtsEngine initialization', () {
    final engine = NativeTtsEngine();
    expect(engine, isNotNull);
    engine.dispose();
  });
}
