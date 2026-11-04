/// Task 1444: Academic register index (nominalization and passive density)
class AcademicRegisterIndex {
  double calculateRegisterScore(int nominalizations, int passives, int wordCount) => wordCount > 0 ? ((nominalizations + passives) / wordCount) * 100.0 : 0.0;
}
