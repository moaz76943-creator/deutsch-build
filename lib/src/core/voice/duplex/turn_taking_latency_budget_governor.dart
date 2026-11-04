/// Task 1124: Turn-taking latency budget optimizer enforcing <150ms response
class TurnTakingLatencyBudget {
  int targetBudgetMs = 150;
  bool isWithinBudget(int elapsedMs) => elapsedMs <= targetBudgetMs;
}
