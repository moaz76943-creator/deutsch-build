import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/models/vocabulary_item.dart';

void main() {
  test('VocabularyItem serialization and deserialization test', () {
    final item = VocabularyItem(
      word: 'Arbeit',
      article: 'die',
      plural: 'Arbeiten',
      preposition: 'an',
      collocation: 'eine Arbeit schreiben',
      wordFamily: 'arbeiten, Arbeiter',
      difficultyScore: 1.0,
      meaning: 'عمل',
      example: 'Das ist eine schwere Arbeit.',
    );

    final json = item.toJson();
    final deserialized = VocabularyItem.fromJson(json);

    expect(deserialized.word, 'Arbeit');
    expect(deserialized.article, 'die');
    expect(deserialized.wordFamily, 'arbeiten, Arbeiter');
    expect(deserialized.difficultyScore, 1.0);
  });
}
