import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/semantic_search/chunk_window_slicer.dart';

void main() {
  group('SemanticChunkWindowSlicer Unit Tests (N044)', () {
    const slicer = SemanticChunkWindowSlicer(targetChunkWords: 15, overlapWords: 4);

    test('Slices multi-sentence passage into clean overlapping semantic chunks', () {
      const passage =
          'Deutsch ist eine faszinierende Sprache. Man lernt jeden Tag etwas Neues dazu! '
          'Grammatik kann manchmal herausfordernd sein, aber mit Übung klappt es wunderbar. '
          'Immer wiederholen und sprechen hilft am meisten.';

      final chunks = slicer.sliceText(fullText: passage, defaultCefr: 'B1');

      expect(chunks.length, greaterThanOrEqualTo(2));
      expect(chunks.first.index, equals(0));
      expect(chunks.first.cefrEstimate, equals('B1'));
      expect(chunks.first.text, contains('Deutsch ist eine faszinierende Sprache'));
    });

    test('Empty text yields zero chunks', () {
      expect(slicer.sliceText(fullText: ''), isEmpty);
    });
  });
}
