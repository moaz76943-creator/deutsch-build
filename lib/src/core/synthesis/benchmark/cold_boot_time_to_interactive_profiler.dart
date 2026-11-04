/// Task 1861: Profiler measuring cold boot time-to-interactive under 800ms
class ColdBootProfiler {
  double measureTti(int startUs, int readyUs) => (readyUs - startUs) / 1000.0;
}
