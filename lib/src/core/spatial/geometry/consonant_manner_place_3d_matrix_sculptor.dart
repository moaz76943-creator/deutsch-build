/// Task 1623: 3D Cartesian placement (X=Place, Y=Manner, Z=Voicing)
class ConsonantMatrixSculptor {
  List<double> getConsonantVector(int place, int manner, bool voiced) => [place.toDouble(), manner.toDouble(), voiced ? 1.0 : 0.0];
}
