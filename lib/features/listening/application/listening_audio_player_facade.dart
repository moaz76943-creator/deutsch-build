import '../domain/audio_services.dart';
import '../domain/listening_models.dart';

final class ListeningAudioPlayerFacade implements AudioPlayerFacade {
  const ListeningAudioPlayerFacade(this._player);

  final AudioPlayerService _player;

  @override
  Future<bool> playDrill(
    ListeningDrill drill, {
    ListeningPlaybackSpeed speed = ListeningPlaybackSpeed.normal,
  }) {
    return _player.play(
      AudioPlaybackRequest(
        text: drill.audioText,
        languageCode: drill.languageCode,
        speedFactor: speed.factor,
        conceptId: drill.conceptId ?? drill.id,
        variant: AudioPlaybackVariant.listening,
      ),
    );
  }

  @override
  Future<void> stop() => _player.stop();
}
