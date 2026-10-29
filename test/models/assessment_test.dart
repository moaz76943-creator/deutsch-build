import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/models/assessment.dart';

void main() {
  group('assessmentNormalize', () {
    test('lowercases strings', () {
      expect(assessmentNormalize('HELLO'), 'hello');
      expect(assessmentNormalize('HeLlO'), 'hello');
    });

    test('trims leading and trailing whitespace', () {
      expect(assessmentNormalize('  hello  '), 'hello');
      expect(assessmentNormalize('\t hello \n'), 'hello');
    });

    test('removes trailing punctuation (.!?)', () {
      expect(assessmentNormalize('hello.'), 'hello');
      expect(assessmentNormalize('hello!'), 'hello');
      expect(assessmentNormalize('hello?'), 'hello');
      expect(assessmentNormalize('hello...'), 'hello');
      expect(assessmentNormalize('hello.?!'), 'hello');
    });

    test('does not remove internal punctuation', () {
      expect(assessmentNormalize('hello. world'), 'hello. world');
      expect(assessmentNormalize('hello! world'), 'hello! world');
      expect(assessmentNormalize('hello? world'), 'hello? world');
    });

    test('collapses multiple whitespace characters to a single space', () {
      expect(assessmentNormalize('hello    world'), 'hello world');
      expect(assessmentNormalize('hello \t \n world'), 'hello world');
    });

    test('handles empty and whitespace-only strings', () {
      expect(assessmentNormalize(''), '');
      expect(assessmentNormalize('   '), '');
    });

    test('handles combinations of normalization rules', () {
      expect(assessmentNormalize('  HELLO    WORLD.?!  '), 'hello world');
    });
  });
}
