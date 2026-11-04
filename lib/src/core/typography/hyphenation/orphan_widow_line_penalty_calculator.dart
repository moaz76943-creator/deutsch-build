/// Task 1255: Typographic widow and orphan line elimination penalty calculator
class WidowOrphanPenaltyCalculator {
  int calculatePenalty(int linesOnPage, int totalLines) => (linesOnPage == 1 || linesOnPage == totalLines - 1) ? 500 : 0;
}
