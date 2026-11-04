/// Task 1405: Maps theta ability into CEFR levels (A1 to C1)
class CefrThetaClassifier {
  String classifyLevel(double theta) => theta < -1.0 ? 'A1' : (theta < 0.0 ? 'A2' : (theta < 1.0 ? 'B1' : (theta < 2.0 ? 'B2' : 'C1')));
}
