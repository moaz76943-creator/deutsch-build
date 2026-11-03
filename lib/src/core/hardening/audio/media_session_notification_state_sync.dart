/// Task 1047: Lockscreen media session & status bar notification synchronizer
class MediaSessionNotificationSync {
  String playbackState = 'STOPPED';
  void updateState(String state) => playbackState = state;
  bool get isSessionActive => playbackState == 'PLAYING';
}
