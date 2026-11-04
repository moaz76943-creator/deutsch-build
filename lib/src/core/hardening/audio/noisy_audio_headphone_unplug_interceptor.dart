/// Task 1043: ACTION_AUDIO_BECOMING_NOISY headphone unplug safety auto-pauser
class NoisyAudioInterceptor {
  bool isPlaying = true;
  void onBecomingNoisy() => isPlaying = false;
  bool get isSafePaused => !isPlaying;
}
