/// Task 2033: Positive-Negative (PN-Counter) CRDT tracking learner experience points
class PnCounterXpLedger {
  int _p = 0;
  int _n = 0;
  void increment(int v) => _p += v;
  int get value => _p - _n;
}
