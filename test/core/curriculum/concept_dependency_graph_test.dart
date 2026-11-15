import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/curriculum/concept_dependency_graph.dart';

void main() {
  group('ConceptDependencyGraph Unit Tests (N030)', () {
    final graph = ConceptDependencyGraph();

    setUp(() {
      graph.registerNode(const CompetenceNode(
        id: 'de_art_01',
        title: 'Definite & Indefinite Articles',
        cefrLevel: 'A1',
        prerequisiteIds: [],
      ));
      graph.registerNode(const CompetenceNode(
        id: 'de_akk_01',
        title: 'Accusative Direct Object',
        cefrLevel: 'A1',
        prerequisiteIds: ['de_art_01'],
      ));
      graph.registerNode(const CompetenceNode(
        id: 'de_dat_01',
        title: 'Dative Indirect Object & Prepositions',
        cefrLevel: 'A2',
        prerequisiteIds: ['de_akk_01'],
      ));
    });

    test('Unlocks root concepts with zero prerequisites immediately', () {
      expect(graph.isUnlocked('de_art_01', {}), isTrue);
    });

    test('Locks concepts when foundational prerequisites are missing', () {
      expect(graph.isUnlocked('de_akk_01', {}), isFalse);
      expect(graph.isUnlocked('de_dat_01', {'de_art_01'}), isFalse);

      final missing = graph.getMissingPrerequisites('de_akk_01', {});
      expect(missing.length, equals(1));
      expect(missing.first.id, equals('de_art_01'));
    });

    test('Unlocks dependent concepts once all dependencies are mastered', () {
      expect(graph.isUnlocked('de_akk_01', {'de_art_01'}), isTrue);
      expect(graph.isUnlocked('de_dat_01', {'de_art_01', 'de_akk_01'}), isTrue);
    });

    test('Calculates curriculum progress accurately', () {
      expect(graph.calculateProgress({'de_art_01'}), closeTo(33.33, 0.1));
      expect(graph.calculateProgress({'de_art_01', 'de_akk_01', 'de_dat_01'}), equals(100.0));
    });
  });
}
