/// Task 1143: Voice Onset Time (VOT) meter for plosives
class VoiceOnsetTimeMeter {
  int measureVotMs(int burstTs, int voiceTs) => voiceTs - burstTs;
  bool isAspirated(int votMs) => votMs > 30;
}
