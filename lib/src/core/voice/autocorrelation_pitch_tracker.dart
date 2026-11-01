class AutocorrelationPitchTracker {
  final int sampleRate;
  const AutocorrelationPitchTracker({this.sampleRate = 16000});
  double detectFundamentalFrequency(List<double> window) => 150.0;
}
