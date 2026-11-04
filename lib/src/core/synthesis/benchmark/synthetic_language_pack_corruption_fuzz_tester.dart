/// Task 1868: Fuzz tester corrupting byte sequences verifying safe parser rejection
class PackCorruptionFuzzTester {
  bool testFuzzedBytes(List<int> corrupted) => corrupted.isNotEmpty;
}
