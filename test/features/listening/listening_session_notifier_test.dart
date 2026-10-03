import 'package:deutsch_bilarabi/features/listening/application/listening_session_notifier.dart';
import 'package:deutsch_bilarabi/features/listening/domain/listening_models.dart';
import 'package:deutsch_bilarabi/features/listening/domain/audio_services.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakePlayerFacade implements AudioPlayerFacade {
  final List<ListeningPlaybackSpeed> speeds = <ListeningPlaybackSpeed>[];

  @override
  Future<bool> playDrill(
    ListeningDrill drill, {
    ListeningPlaybackSpeed speed = ListeningPlaybackSpeed.normal,
  }) async {
    speeds.add(speed);
    return true;
  }

  @override
  Future<void> stop() async {}
}

final class _FakeRecorder implements AudioRecorderService {
  _FakeRecorder(this.result);

  final AudioRecordingResult result;
  int captures = 0;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<AudioRecordingResult> capturePronunciation({
    required String targetText,
    List<String> targetPhonemes = const <String>[],
  }) async {
    captures += 1;
    return result;
  }
}

void main() {
  final multipleChoice = ListeningDrill.multipleChoice(
    id: 'mc-1',
    promptArabic: 'اختر ما سمعته',
    audioText: 'Ich hätte gern einen Kaffee.',
    languageCode: 'de',
    options: const <ListeningOption>[
      ListeningOption(id: 'a', text: 'Ich hätte gern einen Kaffee.'),
      ListeningOption(id: 'b', text: 'Ich hätte gern einen Tee.'),
    ],
    correctOptionId: 'a',
  );

  final dictation = ListeningDrill.dictation(
    id: 'dict-1',
    promptArabic: 'اكتب ما تسمعه',
    audioText: 'Guten Morgen!',
    languageCode: 'de',
    expectedText: 'Guten Morgen!',
  );

  test('multiple-choice answer awards points once and advances safely', () {
    final notifier = ListeningSessionNotifier(
      drills: <ListeningDrill>[multipleChoice, dictation],
      player: _FakePlayerFacade(),
      recorder: _FakeRecorder(const AudioRecordingResult.unavailable('unused')),
    );

    final result = notifier.submitOption('a');

    expect(result.correct, isTrue);
    expect(notifier.score, 10);
    expect(notifier.canAdvance, isTrue);
    expect(() => notifier.submitOption('a'), throwsStateError);

    notifier.next();
    expect(notifier.currentDrill.id, 'dict-1');
    expect(notifier.score, 10);
  });

  test('dictation matcher normalizes case whitespace and punctuation', () {
    final notifier = ListeningSessionNotifier(
      drills: <ListeningDrill>[dictation],
      player: _FakePlayerFacade(),
      recorder: _FakeRecorder(const AudioRecordingResult.unavailable('unused')),
    );

    final result = notifier.submitDictation('  GUTEN   MORGEN  ');

    expect(result.correct, isTrue);
    expect(notifier.score, 10);
    expect(result.normalizedExpected, 'guten morgen');
    expect(result.normalizedAnswer, 'guten morgen');
  });

  test('slow replay is delegated at 0.8x through the audio facade', () async {
    final player = _FakePlayerFacade();
    final notifier = ListeningSessionNotifier(
      drills: <ListeningDrill>[multipleChoice],
      player: player,
      recorder: _FakeRecorder(const AudioRecordingResult.unavailable('unused')),
    );

    final played = await notifier.playCurrent(ListeningPlaybackSpeed.slow);

    expect(played, isTrue);
    expect(player.speeds, <ListeningPlaybackSpeed>[ListeningPlaybackSpeed.slow]);
  });

  test('pronunciation feedback exposes phoneme accuracy only when measured', () async {
    final recorder = _FakeRecorder(
      const AudioRecordingResult.available(
        recognizedText: 'Brot',
        recognizedPhonemes: <String>['b', 'ʁ', 'oː', 't'],
      ),
    );
    final drill = ListeningDrill.dictation(
      id: 'pron-1',
      promptArabic: 'انطق الكلمة',
      audioText: 'Brot',
      languageCode: 'de',
      expectedText: 'Brot',
      targetPhonemes: const <String>['b', 'ʁ', 'oː', 't'],
    );
    final notifier = ListeningSessionNotifier(
      drills: <ListeningDrill>[drill],
      player: _FakePlayerFacade(),
      recorder: recorder,
    );

    final feedback = await notifier.evaluatePronunciation();

    expect(recorder.captures, 1);
    expect(feedback.phonemeAccuracyAvailable, isTrue);
    expect(feedback.accuracy, 1);
    expect(feedback.phonemeMatches, hasLength(4));
  });

  test('pronunciation engine never invents phoneme accuracy', () async {
    final recorder = _FakeRecorder(
      const AudioRecordingResult.available(recognizedText: 'Brot'),
    );
    final drill = ListeningDrill.dictation(
      id: 'pron-2',
      promptArabic: 'انطق الكلمة',
      audioText: 'Brot',
      languageCode: 'de',
      expectedText: 'Brot',
      targetPhonemes: const <String>['b', 'ʁ', 'oː', 't'],
    );
    final notifier = ListeningSessionNotifier(
      drills: <ListeningDrill>[drill],
      player: _FakePlayerFacade(),
      recorder: recorder,
    );

    final feedback = await notifier.evaluatePronunciation();

    expect(feedback.phonemeAccuracyAvailable, isFalse);
    expect(feedback.accuracy, isNull);
    expect(feedback.messageArabic, contains('الفونيم'));
  });
}
