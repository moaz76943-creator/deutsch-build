import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/models/assessment.dart';

void main() {
  group('assessmentNormalize', () {
    test('lowercases strings', () {
      expect(assessmentNormalize('HELLO'), 'hello');
      expect(assessmentNormalize('HeLlO'), 'hello');
    });

    test('trims whitespace', () {
      expect(assessmentNormalize('  hello  '), 'hello');
      expect(assessmentNormalize('\thello\n'), 'hello');
    });

    test('collapses multiple whitespace characters', () {
      expect(assessmentNormalize('hello   world'), 'hello world');
      expect(assessmentNormalize('hello \t\n world'), 'hello world');
    });

    test('removes trailing punctuation', () {
      expect(assessmentNormalize('hello.'), 'hello');
      expect(assessmentNormalize('hello!'), 'hello');
      expect(assessmentNormalize('hello?'), 'hello');
      expect(assessmentNormalize('hello.!?'), 'hello');
    });

    test('leaves internal punctuation intact', () {
      expect(assessmentNormalize('hello, world!'), 'hello, world');
      expect(assessmentNormalize('hello.world!'), 'hello.world');
      expect(assessmentNormalize('what\'s up?'), 'what\'s up');
    });

    test('handles empty and whitespace-only strings', () {
      expect(assessmentNormalize(''), '');
      expect(assessmentNormalize('   '), '');
      expect(assessmentNormalize(' .!? '), '');
    });

    test('handles mixed combinations', () {
      expect(assessmentNormalize('  HELLO \t\n WORLD.!?  '), 'hello world');
    });
  });
}
