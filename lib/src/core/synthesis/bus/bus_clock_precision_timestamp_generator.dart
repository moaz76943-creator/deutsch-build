/// Task 1837: Nanosecond monotonic clock generator for distributed event tracing
class BusMonotonicClock {
  int getNowMicros() => DateTime.now().microsecondsSinceEpoch;
}
