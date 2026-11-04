/// Task 1823: Backpressure governor dynamically dropping low-priority UI telemetry
class EventBackpressureGovernor {
  bool shouldDrop(int queueDepth) => queueDepth > 100;
}
