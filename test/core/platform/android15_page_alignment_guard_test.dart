import 'package:test/test.dart';
import 'package:deutsch_build/src/core/platform/android15_page_alignment_guard.dart';

void main() {
  group('Android15PageAlignmentGuard Tests', () {
    test('Identifies compliant 16KB page alignment status', () {
      const guard = Android15PageAlignmentGuard(detectedPageSize: 16384);

      expect(guard.isAndroid15Compliant, isTrue);
      expect(guard.alignmentStatus, equals(PageAlignmentStatus.aligned16Kb));
      expect(guard.verifyAllocationOffset(0x4000), isTrue);
      expect(guard.verifyAllocationOffset(0x8000), isTrue);
      expect(guard.verifyAllocationOffset(0x1000), isFalse); // 4KB offset not 16KB aligned
    });

    test('Identifies legacy 4KB page size', () {
      const guard = Android15PageAlignmentGuard(detectedPageSize: 4096);

      expect(guard.isAndroid15Compliant, isFalse);
      expect(guard.alignmentStatus, equals(PageAlignmentStatus.legacy4Kb));
    });
  });
}
