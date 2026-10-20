import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/models/mistake.dart';

void main() {
  group('mistakeCategoryLabel', () {
    test('returns correct label for vocabulary', () {
      expect(mistakeCategoryLabel(MistakeCategory.vocabulary), 'مفردات');
    });

    test('returns correct label for article', () {
      expect(mistakeCategoryLabel(MistakeCategory.article), 'Artikel');
    });

    test('returns correct label for grammar', () {
      expect(mistakeCategoryLabel(MistakeCategory.grammar), 'قواعد');
    });

    test('returns correct label for translation', () {
      expect(mistakeCategoryLabel(MistakeCategory.translation), 'ترجمة');
    });

    test('returns correct label for wordOrder', () {
      expect(mistakeCategoryLabel(MistakeCategory.wordOrder), 'ترتيب الجملة');
    });

    test('returns correct label for writing', () {
      expect(mistakeCategoryLabel(MistakeCategory.writing), 'كتابة');
    });

    test('returns correct label for production', () {
      expect(mistakeCategoryLabel(MistakeCategory.production), 'إنتاج');
    });

    test('returns correct label for listening', () {
      expect(mistakeCategoryLabel(MistakeCategory.listening), 'استماع');
    });
  });
}
