/// Task 1135: Zero-latency comfort noise & silence packet injector
class JitterPacketInjector {
  int injectedPackets = 0;
  void injectComfortNoise() => injectedPackets++;
}
