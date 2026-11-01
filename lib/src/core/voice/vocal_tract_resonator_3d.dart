class VocalTractResonator3D {
  final int tubeSections;
  const VocalTractResonator3D({this.tubeSections = 8});
  List<double> filterResonance(List<double> glottalWave) => List.from(glottalWave);
}
