class PrivacyFriendlyCrashLogSanitizer {
  String sanitizeTrace(String rawTrace) =>
      rawTrace.replaceAll(RegExp(r'/data/user/\d+/[^/]+'), '/SANDBOX_DIR');
}
