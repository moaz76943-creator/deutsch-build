import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/embedded_audio_streamer.dart';

class MemorySource implements EmbeddedOpusSource {
  MemorySource(this.bytes);
  final Uint8List? bytes;
  @override
  Future<Uint8List?> read(String _) async => bytes;
}

class FakePlayer implements EmbeddedOpusPlayer {
  int plays=0;
  int stops=0;
  Uint8List? received;
  @override
  Future<bool> play(Uint8List bytes) async {
    plays++;
    received=bytes;
    return true;
  }
  @override
  Future<void> stop() async { stops++; }
}

void main() {
  test('valid Ogg header is sent without writing a temporary file', () async {
    final data=Uint8List.fromList([79,103,103,83,0,0,0,0,1]);
    final player=FakePlayer();
    final engine=EmbeddedAudioStreamer(
        source:MemorySource(data),player:player);
    expect(await engine.playClip('clip-1'),isTrue);
    expect(identical(player.received,data),isTrue);
    await engine.stop();
    expect(player.stops,1);
  });
  test('missing, invalid and oversized clips do not start playback', () async {
    final player=FakePlayer();
    expect(await EmbeddedAudioStreamer(
        source:MemorySource(null),player:player).playClip('missing'),isFalse);
    final engine=EmbeddedAudioStreamer(
        source:MemorySource(null),player:player);
    expect(await engine.playBytes(Uint8List.fromList([1,2,3,4,5,6,7,8])),
        isFalse);
    expect(await engine.playBytes(Uint8List(
        EmbeddedAudioStreamer.maximumClipBytes+1)),isFalse);
    expect(player.plays,0);
  });
}
