/// Task 1455: Monitors excessive loanwords in formal writing
class LoanwordDensityMeter {
  double calculateLoanwordRatio(int loanwordCount, int totalWords) => totalWords > 0 ? (loanwordCount / totalWords) * 100.0 : 0.0;
}
