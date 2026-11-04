/// Task 1931: Turn-taking buffer modeling human pause durations
class TurnTakingJitterBuffer {
  int computePauseMs(String intent, String cefr) => cefr == 'A1' ? 750 : 350;
}
