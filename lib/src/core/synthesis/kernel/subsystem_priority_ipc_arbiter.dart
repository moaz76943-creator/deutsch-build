/// Task 1811: Priority IPC arbiter scheduling urgent audio/render events
class PriorityIpcArbiter {
  int prioritize(String eventType) => eventType.startsWith('AUDIO') ? 0 : 5;
}
