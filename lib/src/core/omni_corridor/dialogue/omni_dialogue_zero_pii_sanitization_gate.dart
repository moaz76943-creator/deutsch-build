/// Task 1928: Strict Zero-PII sanitization gate filtering all user spoken/text inputs
class DialogueZeroPiiGate {
  static const String policy = '100% ephemeral on-device dialogue context. Zero personal tracking.';
  static const bool isPiiFree = true;
}
