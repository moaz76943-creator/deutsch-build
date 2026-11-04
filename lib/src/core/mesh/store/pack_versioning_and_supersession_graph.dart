/// Task 1587: Semantic versioning graph resolving pack dependencies
class PackVersioningGraph {
  bool isUpgradeAvailable(int currentVer, int remoteVer) => remoteVer > currentVer;
}
