/// Task 1814: Dynamic decoupling proxy preventing circular import lockouts
class CircularDependencyBreaker {
  bool isAcyclic(List<String> path) => path.toSet().length == path.length;
}
