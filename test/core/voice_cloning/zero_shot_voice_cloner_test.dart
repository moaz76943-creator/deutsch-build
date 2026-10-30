import 'package:test/test.dart';
import '../../lib/src/core/voice_cloning/zero_shot_voice_cloner.dart';

void main() {
  test('N001: ZeroShotVoiceCloner extracts valid embedding', () {
    final cloner = const ZeroShotVoiceCloner();
    final pcm = List<double>.filled(48000 * 3, 0.1);
    final emb = cloner.extractEmbedding(pcm, 48000);
    expect(emb.dimension, equals(192));
    expect(cloner.isQualitySufficient(emb), isTrue);
  });
}
