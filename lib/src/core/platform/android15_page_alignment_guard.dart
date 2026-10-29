/// Platform runtime alignment status for Android 15 compatibility.
enum PageAlignmentStatus {
  aligned16Kb, // Conforming to Android 15 requirements
  legacy4Kb,   // Legacy Android 14 and earlier
  unknown,
}

/// Guards native library invocations ensuring 16KB page-size alignment compliance.
class Android15PageAlignmentGuard {
  static const int standard16KbPageSize = 16384; // 0x4000

  final int detectedPageSize;

  const Android15PageAlignmentGuard({this.detectedPageSize = standard16KbPageSize});

  bool get isAndroid15Compliant => detectedPageSize % standard16KbPageSize == 0;

  PageAlignmentStatus get alignmentStatus {
    if (detectedPageSize == standard16KbPageSize) {
      return PageAlignmentStatus.aligned16Kb;
    } else if (detectedPageSize == 4096) {
      return PageAlignmentStatus.legacy4Kb;
    }
    return PageAlignmentStatus.unknown;
  }

  /// Verifies memory allocation offset aligns cleanly to page boundary.
  bool verifyAllocationOffset(int offset) {
    return offset % detectedPageSize == 0;
  }
}
