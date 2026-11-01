class ConversationalOverlapSynthesizer {
  const ConversationalOverlapSynthesizer();
  List<double> duckAudio(List<double> tutorAudio, double duckingFactor) {
    return tutorAudio.map((s) => s * duckingFactor).toList();
  }
}
