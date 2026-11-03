/// Task 1238: Validates OpenType table directory checksums
class FontChecksumValidator {
  bool verifyTableChecksum(int computedSum, int expectedSum) => computedSum == expectedSum;
}
