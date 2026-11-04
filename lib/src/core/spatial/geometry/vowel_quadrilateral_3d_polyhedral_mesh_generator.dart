/// Task 1621: 3D polygonal mesh of the IPA vowel space (Front-Back, High-Low)
class VowelMeshGenerator {
  List<double> getVowelCoordinates(String vowel) => vowel == 'i' ? [0.1, 0.9, 0.0] : (vowel == 'u' ? [0.9, 0.9, 1.0] : [0.5, 0.1, 0.0]);
}
