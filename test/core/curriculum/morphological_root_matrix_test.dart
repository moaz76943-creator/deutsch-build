import 'package:test/test.dart';
import '../../lib/src/core/curriculum/morphological_root_matrix.dart';

void main() {
  group('MorphologicalRootMatrix Unit Tests (N024)', () {
    final matrix = MorphologicalRootMatrix();

    test('Deconstructs complex German derived noun with prefix and suffix', () {
      final breakdown = matrix.deconstruct(
        'Verbindung',
        knownFamily: ['binden', 'Gebund', 'Bund'],
      );

      expect(breakdown.originalWord, equals('Verbindung'));
      expect(breakdown.prefixes, contains('ver'));
      expect(breakdown.suffixes, contains('ung'));
      expect(breakdown.root, equals('bind'));
      expect(breakdown.wordClass, equals('noun'));
      expect(breakdown.derivedFamily.length, equals(3));
    });

    test('Detects potential adjective suffix bar', () {
      final breakdown = matrix.deconstruct('machbar');
      expect(breakdown.suffixes, contains('bar'));
      expect(breakdown.wordClass, equals('adjective'));
      expect(breakdown.root, equals('mach'));
    });

    test('Calculates complexity index accurately', () {
      final simple = matrix.deconstruct('Hund');
      final complex = matrix.deconstruct('Verbindlichkeit');

      expect(matrix.calculateComplexity(complex), greaterThan(matrix.calculateComplexity(simple)));
    });
  });
}
