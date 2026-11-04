/// Task 1658: Hardware proximity sensor putting 3D engine to sleep in pocket
class ProximitySleepLock {
  bool shouldSleep(double distanceCm) => distanceCm < 2.0;
}
