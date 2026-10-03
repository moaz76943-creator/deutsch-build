import 'package:deutsch_bilarabi/features/listening/application/listening_audio_player_facade.dart';
import 'package:deutsch_bilarabi/features/listening/domain/audio_services.dart';
import 'package:deutsch_bilarabi/features/listening/domain/listening_models.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakePlayerService implements AudioPlayerService {
  AudioPlaybackRequest? request;

  @override
  Future<bool> play(AudioPlaybackRequest value) async {
    request = value;
    return true;
  }

  @override
  Future<void> stop() async {}
}

void main() {
  test('facade converts listening replay speed without exposing infrastructure', () async {
    final service = _FakePlayerService();
    final facade = ListeningAudioPlayerFacade(service);
    final drill = ListeningDrill.dictation(
      id: 'd1',
      promptArabic: 'اكتب ما تسمعه',
      audioText: 'Wie geht es dir?',
      languageCode: 'de',
      expectedText: 'Wie geht es dir?',
    );

    await facade.playDrill(drill, speed: ListeningPlaybackSpeed.slow);

    expect(service.request?.text, 'Wie geht es dir?');
    expect(service.request?.languageCode, 'de');
    expect(service.request?.rate, .8);
    expect(service.request?.variant, AudioPlaybackVariant.listening);
  });
}
