import 'package:test/test.dart';
import 'package:deutsch_build/src/core/audio/android15_audio_policy_manager.dart';

class MockAndroid15AudioBridge implements Android15PlatformAudioBridge {
  bool serviceStarted = false;
  double activeVolume = 1.0;

  @override
  Future<bool> startMediaPlaybackService({required String channelId, required String title, required String speaker}) async {
    serviceStarted = true;
    return true;
  }

  @override
  Future<void> stopMediaPlaybackService() async {
    serviceStarted = false;
  }

  @override
  Future<void> setVolume(double factor) async {
    activeVolume = factor;
  }
}

void main() {
  group('Android15AudioPolicyManager Tests', () {
    late MockAndroid15AudioBridge bridge;
    late Android15AudioPolicyManager manager;

    setUp(() {
      bridge = MockAndroid15AudioBridge();
      manager = Android15AudioPolicyManager(bridge: bridge);
    });

    test('Starts foreground service with proper media metadata', () async {
      expect(manager.isPlayingInBackground, isFalse);

      final ok = await manager.startPlaybackSession(
        wordOrSentence: 'Guten Morgen',
        speakerName: 'Thorsten',
      );

      expect(ok, isTrue);
      expect(manager.isPlayingInBackground, isTrue);
      expect(manager.state.currentTitle, equals('Guten Morgen'));
      expect(bridge.serviceStarted, isTrue);
    });

    test('Applies audio ducking to 20% on transient loss and restores on gain', () async {
      await manager.startPlaybackSession(wordOrSentence: 'Test', speakerName: 'Test');

      // System notification arrives -> duck
      await manager.handleFocusChange(AudioFocusState.lossTransientCanDuck);
      expect(manager.state.volumeDuckingFactor, equals(0.2));
      expect(bridge.activeVolume, equals(0.2));

      // System notification clears -> restore
      await manager.handleFocusChange(AudioFocusState.gain);
      expect(manager.state.volumeDuckingFactor, equals(1.0));
      expect(bridge.activeVolume, equals(1.0));
    });

    test('Stops service cleanly on session termination', () async {
      await manager.startPlaybackSession(wordOrSentence: 'Test', speakerName: 'Test');
      await manager.stopPlaybackSession();

      expect(manager.isPlayingInBackground, isFalse);
      expect(bridge.serviceStarted, isFalse);
    });
  });
}
