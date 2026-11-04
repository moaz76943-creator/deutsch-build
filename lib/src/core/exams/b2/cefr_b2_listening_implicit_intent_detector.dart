class CefrB2ListeningImplicitIntentDetector {
  bool isIronyDetected(String toneMarker) => toneMarker.contains('تلميح ساخر') || toneMarker.contains('تهكم خفي');
}
