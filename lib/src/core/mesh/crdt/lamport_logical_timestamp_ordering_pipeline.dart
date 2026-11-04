/// Task 1535: Lamport scalar timestamp generator ensuring total ordering
class LamportTimestampPipeline {
  int _clock = 0;
  int tick() => ++_clock;
  void witness(int remoteClock) => _clock = (_clock > remoteClock ? _clock : remoteClock) + 1;
}
