/// Task 1174: Gradual speaking tempo accelerator (A1 slow to C1 native)
class DialogueTempoRegulator {
  double getTempoForLevel(String level) => level == 'A1' ? 0.75 : (level == 'B1' ? 1.0 : 1.15);
}
