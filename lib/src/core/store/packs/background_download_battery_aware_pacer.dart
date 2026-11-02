class BackgroundDownloadBatteryAwarePacer {
  bool shouldDownload(bool isWifi, int batteryPercent) => isWifi && batteryPercent >= 20;
}
