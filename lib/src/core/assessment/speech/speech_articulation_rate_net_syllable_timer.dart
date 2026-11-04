/// Task 1423: Net articulation rate timer excluding silent pauses
class ArticulationRateTimer {
  double getArticulationVelocity(int syllables, double speechSecWithoutPauses) => speechSecWithoutPauses > 0 ? syllables / speechSecWithoutPauses : 0.0;
}
