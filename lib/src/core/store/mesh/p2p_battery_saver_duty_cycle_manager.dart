class P2pBatterySaverDutyCycleManager {
  int getScanWindowSeconds(int batteryPercent) => batteryPercent < 20 ? 5 : 15;
}
