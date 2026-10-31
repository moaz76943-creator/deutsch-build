class NativeAccentMorpher {
  final double nativeTargetWeight;
  const NativeAccentMorpher({this.nativeTargetWeight = 0.65});

  List<double> morphVoiceEmbedding({required List<double> learnerVec, required List<double> nativeCentroidVec}) {
    if (learnerVec.length != nativeCentroidVec.length) return learnerVec;
    return List<double>.generate(learnerVec.length, (i) {
      return (learnerVec[i] * (1.0 - nativeTargetWeight)) + (nativeCentroidVec[i] * nativeTargetWeight);
    });
  }
}
