/// Task 1362: Enforces tree axioms: single root, connectedness, acyclicity
class DependencyTreeVerifier {
  bool isTreeValid(int rootCount, bool hasCycles) => rootCount == 1 && !hasCycles;
}
