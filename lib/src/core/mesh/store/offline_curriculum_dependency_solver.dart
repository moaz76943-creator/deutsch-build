/// Task 1597: Dependency graph solver computing missing prerequisite lessons
class CurriculumDependencySolver {
  List<String> getMissingPrerequisites(List<String> required, Set<String> installed) => required.where((r) => !installed.contains(r)).toList();
}
