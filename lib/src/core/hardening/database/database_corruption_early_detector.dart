/// Task 1023: Early PRAGMA integrity check on startup & corruption detector
class DbCorruptionEarlyDetector {
  bool checkIntegrity(String pragmaResult) => pragmaResult.trim().toLowerCase() == 'ok';
  bool needsRecovery(bool isOk) => !isOk;
}
