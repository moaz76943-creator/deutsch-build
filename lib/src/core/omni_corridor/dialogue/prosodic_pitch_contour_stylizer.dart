/// Task 1932: Pitch contour stylizer shaping expressive intonation
class ProsodicPitchContourStylizer {
  List<double> generatePitchCurve(String sentenceType) => sentenceType == 'QUESTION' ? [120.0, 180.0] : [140.0, 110.0];
}
