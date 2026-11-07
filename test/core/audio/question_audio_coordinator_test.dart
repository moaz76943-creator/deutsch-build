import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/audio/question_audio_coordinator.dart';

class MockAudioPlayerClient implements AudioPlayerClient {
  String? currentlyPlayingUri;
  bool isPlaying = false;
  int playCallCount = 0;

  @override
  Future<void> playAudioUri(String uri) async {
    currentlyPlayingUri = uri;
    isPlaying = true;
    playCallCount++;
  }

  @override
  Future<void> stop() async {
    isPlaying = false;
    currentlyPlayingUri = null;
  }

  @override
  Future<void> release() async {
    await stop();
  }
}

void main() {
  group('QuestionAudioCoordinator Stale Audio Prevention Tests', () {
    late MockAudioPlayerClient mockPlayer;
    late QuestionAudioCoordinator coordinator;

    setUp(() {
      mockPlayer = MockAudioPlayerClient();
      coordinator = QuestionAudioCoordinator(mockPlayer);
    });

    tearDown(() async {
      await coordinator.dispose();
    });

    test('Discards delayed audio playback from Q1 when user transitions to Q2 mid-loading', () async {
      // 1. User starts Question 1 (slow TTS synthesis, 50ms)
      final q1Playback = coordinator.requestQuestionAudio(
        questionId: 'question_001',
        audioUriResolver: () async {
          await Future.delayed(const Duration(milliseconds: 50));
          return 'audio://cache/q1_pronunciation.mp3';
        },
      );

      // 2. User quickly taps Next to Question 2 after 10ms
      await Future.delayed(const Duration(milliseconds: 10));
      await coordinator.transitionToQuestion('question_002');

      // 3. User requests audio for Question 2 (fast, 10ms)
      final q2Playback = coordinator.requestQuestionAudio(
        questionId: 'question_002',
        audioUriResolver: () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return 'audio://cache/q2_pronunciation.mp3';
        },
      );

      final results = await Future.wait([q1Playback, q2Playback]);

      // Assert Q1 was dropped (false) and Q2 succeeded (true)
      expect(results[0], isFalse);
      expect(results[1], isTrue);

      // Assert only Question 2 audio was sent to player
      expect(mockPlayer.playCallCount, equals(1));
      expect(mockPlayer.currentlyPlayingUri, equals('audio://cache/q2_pronunciation.mp3'));
    });
  });
}
