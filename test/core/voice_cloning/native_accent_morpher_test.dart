import 'package:test/test.dart';
import '../../lib/src/core/voice_cloning/native_accent_morpher.dart';

void main() {
  test('N002: NativeAccentMorpher interpolates embeddings', () {
    const morpher = NativeAccentMorpher(nativeTargetWeight: 0.5);
    final morphed = morpher.morphVoiceEmbedding(learnerVec: [0.0, 1.0], nativeCentroidVec: [1.0, 0.0]);
    expect(morphed, equals([0.5, 0.5]));
  });
}
