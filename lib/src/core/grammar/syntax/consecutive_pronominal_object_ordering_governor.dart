/// Task 1317: Pronoun ordering rule (Akkusativ before Dativ for pronouns)
class PronominalOrderGovernor {
  bool isCorrectOrder(String firstPronounCase, String secondPronounCase) => firstPronounCase == 'Akkusativ' && secondPronounCase == 'Dativ';
}
