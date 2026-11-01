class RealtimeProsodicAlignmentCorrector {
  const RealtimeProsodicAlignmentCorrector();
  double computeCadenceDelta(double learnerTempoWpm, double referenceTempoWpm) {
    return (learnerTempoWpm - referenceTempoWpm).abs();
  }
}
