import 'package:test/test.dart';
import '../../lib/src/core/curriculum/syntactic_dependency_visualizer.dart';

void main() {
  group('SyntacticDependencyVisualizer Unit Tests (N028)', () {
    final visualizer = SyntacticDependencyVisualizer();

    test('Renders clean ASCII dependency hierarchy', () {
      final nodes = [
        const DependencyNode(id: 1, text: 'Der', pos: 'DET', relation: 'det', headId: 2),
        const DependencyNode(id: 2, text: 'Hund', pos: 'NOUN', relation: 'nsubj', headId: 3),
        const DependencyNode(id: 3, text: 'schläft', pos: 'VERB', relation: 'root', headId: 0),
      ];

      final tree = visualizer.renderAsciiTree(nodes);
      expect(tree, contains('[ROOT] schläft (VERB)'));
      expect(tree, contains('nsubj: Hund (NOUN)'));
      expect(tree, contains('det: Der (DET)'));
    });

    test('Detects German sentence bracket (Satzklammer) spanning objects', () {
      final nodes = [
        const DependencyNode(id: 1, text: 'Ich', pos: 'PRON', relation: 'nsubj', headId: 2),
        const DependencyNode(id: 2, text: 'habe', pos: 'AUX', relation: 'root', headId: 0),
        const DependencyNode(id: 3, text: 'den', pos: 'DET', relation: 'det', headId: 4),
        const DependencyNode(id: 4, text: 'Film', pos: 'NOUN', relation: 'obj', headId: 2),
        const DependencyNode(id: 5, text: 'gesehen', pos: 'VERB', relation: 'xcomp', headId: 2),
      ];

      expect(visualizer.hasSatzklammer(nodes), isTrue);
    });

    test('Empty node list handles safely', () {
      expect(visualizer.renderAsciiTree([]), equals('(empty tree)'));
      expect(visualizer.hasSatzklammer([]), isFalse);
    });
  });
}
