class SpeechIntonationFeedbackAligner {
  const SpeechIntonationFeedbackAligner();
  bool isRisingQuestion(List<double> pitch) {
    if (pitch.length < 2) return false;
    return pitch.last > pitch.first;
  }
}
