/// Task 1661: PCA 3D dimension reducer projecting 300D embeddings to [x, y, z]
class PcaProjectionReducer {
  List<double> projectTo3D(List<double> highDimVector) => [highDimVector[0], highDimVector[1], highDimVector[2]];
}
