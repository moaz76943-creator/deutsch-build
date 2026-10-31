import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/core/golden_content_validator.dart';
import 'package:deutsch_bilarabi/core/atomic_attempt_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  group('Golden Content Validator Tests', () {
    test('يتحقق من صحة أداة التعريف der/die/das', () {
      final valid = GoldenContentValidator.validateEntry(
        targetWord: 'Tisch',
        sourceTranslation: 'طاولة',
        article: 'der',
      );
      expect(valid.isValid, isTrue);

      final invalid = GoldenContentValidator.validateEntry(
        targetWord: 'Tisch',
        sourceTranslation: 'طاولة',
        article: 'den',
      );
      expect(invalid.isValid, isFalse);
      expect(invalid.issues.any((i) => i.contains('أداة التعريف')), isTrue);
    });

    test('يكتشف الحقول الفارغة أو التكرار المشبوه', () {
      final emptyWord = GoldenContentValidator.validateEntry(
        targetWord: '',
        sourceTranslation: 'ترجمة',
      );
      expect(emptyWord.isValid, isFalse);

      final suspicious = GoldenContentValidator.validateEntry(
        targetWord: 'Spieeelen',
        sourceTranslation: 'يلعب',
      );
      expect(suspicious.isValid, isFalse);
    });
  });

  group('Atomic Attempt Persistence Tests', () {
    setUp(() {
      AtomicAttemptManager.debugReset();
      SharedPreferences.setMockInitialValues(<String, Object>{});
      AtomicAttemptManager.debugAllowPlatform = true;
    });

    tearDown(AtomicAttemptManager.debugReset);

    test('يمنع معالجة نفس المحاولة أكثر من مرة', () async {
      const attemptId = 'task_101_attempt';

      expect(await AtomicAttemptManager.isAttemptProcessed(attemptId), isFalse);
      await AtomicAttemptManager.markAttemptProcessed(attemptId);
      expect(await AtomicAttemptManager.isAttemptProcessed(attemptId), isTrue);
      await AtomicAttemptManager.markAttemptProcessed(attemptId);
      expect(await AtomicAttemptManager.isAttemptProcessed(attemptId), isTrue);
    });

    test('يعيد القراءة من المخزن بعد مسح الذاكرة', () async {
      const attemptId = 'task_202_attempt';
      await AtomicAttemptManager.markAttemptProcessed(attemptId);

      AtomicAttemptManager.debugForgetProcessedMemory();
      expect(await AtomicAttemptManager.isAttemptProcessed(attemptId), isTrue);
    });

    test('لا ينتظر قناة المنصة عندما يكون الاختبار بلا مخزن وهمي', () async {
      AtomicAttemptManager.debugAllowPlatform = false;
      const attemptId = 'task_303_attempt';

      await AtomicAttemptManager.markAttemptProcessed(attemptId);
      expect(await AtomicAttemptManager.isAttemptProcessed(attemptId), isTrue);
    });
  });
}
