enum AudioFocusState { gained, lossTransient, lossPermanent }
class AudioFocusLossGracefulPauser {
  bool shouldPause(AudioFocusState state) => state != AudioFocusState.gained;
}
