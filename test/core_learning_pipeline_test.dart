import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/core/golden_content_validator.dart';
import 'package:deutsch_bilarabi/core/atomic_attempt_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
    test('يمنع معالجة نفس المحاولة أكثر من مرة', () async {
      SharedPreferences.setMockInitialValues({});
      const attemptId = 'task_101_attempt';

      expect(await AtomicAttemptManager.isAttemptProcessed(attemptId), isFalse);
      await AtomicAttemptManager.markAttemptProcessed(attemptId);
      expect(await AtomicAttemptManager.isAttemptProcessed(attemptId), isTrue);
    });
  });
}
