import 'package:deutsch_bilarabi/services/grammar_hub_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, Object?> row(String encoded) => {
        'topic_id': 'test-only',
        'question': 'q',
        'options_json': encoded,
        'correct_index': 0,
        'explanation': 'e',
      };
  test('quiz options preserve Unicode and order', () {
    expect(GrammarQuiz.fromMap(row('["أ","ü","字"]')).options, ['أ', 'ü', '字']);
  });
  test('non-list and non-string options are rejected', () {
    for (final encoded in ['{}', 'null', '["a",1]']) {
      expect(() => GrammarQuiz.fromMap(row(encoded)), throwsFormatException);
    }
  });
}
