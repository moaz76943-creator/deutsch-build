import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/audio/oboe_audio_driver.dart';

class MockOboeBridge implements OboePlatformBridge {
  bool isOpen = false;
  bool isPaused = false;
  int writtenBytes = 0;

  @override
  Future<bool> openStream(AudioStreamConfig config) async {
    isOpen = true;
    return true;
  }

  @override
  Future<int> writePcmData(Uint8List pcmBytes) async {
    writtenBytes += pcmBytes.lengthInBytes;
    return pcmBytes.lengthInBytes;
  }

  @override
  Future<void> pauseStream() async {
    isPaused = true;
  }

  @override
  Future<void> resumeStream() async {
    isPaused = false;
  }

  @override
  Future<void> closeStream() async {
    isOpen = false;
  }

  @override
  Future<int> getXRunCount() async => 0;
}

void main() {
  group('OboeAudioDriver Tests', () {
    late MockOboeBridge bridge;
    late OboeAudioDriver driver;

    setUp(() {
      bridge = MockOboeBridge();
      driver = OboeAudioDriver(bridge: bridge);
    });

    test('Initializes Oboe stream and verifies active state', () async {
      expect(driver.isStreamOpen, isFalse);

      final ok = await driver.initialize();
      expect(ok, isTrue);
      expect(driver.isStreamOpen, isTrue);
      expect(bridge.isOpen, isTrue);
    });

    test('Writes PCM buffer and handles zero latency playback', () async {
      final samplePcm = Uint8List(1024);
      final success = await driver.playPcm(samplePcm);

      expect(success, isTrue);
      expect(bridge.writtenBytes, equals(1024));
      expect(driver.underflowCount, equals(0));
    });

    test('Pauses on audio focus loss and resumes cleanly', () async {
      await driver.initialize();
      await driver.onAudioFocusLost();
      expect(bridge.isPaused, isTrue);

      await driver.onAudioFocusGained();
      expect(bridge.isPaused, isFalse);

      await driver.dispose();
      expect(driver.isStreamOpen, isFalse);
    });
  });
}
