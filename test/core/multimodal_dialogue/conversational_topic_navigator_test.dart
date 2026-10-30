import 'package:test/test.dart';
import '../../lib/src/core/multimodal_dialogue/conversational_topic_navigator.dart';

void main() {
  group('ConversationalTopicNavigator Unit Tests (N073)', () {
    final navigator = ConversationalTopicNavigator();

    test('Suggests engaging open-ended questions for food topic', () {
      final question = navigator.suggestFollowUpQuestion('food');
      expect(question, contains('kochst du am liebsten'));
    });

    test('Navigates from food to connected topic smoothly', () {
      final nextTopic = navigator.suggestNextTopic('food');
      expect(nextTopic, equals('culture'));
    });

    test('Handles unknown topic with fallback question', () {
      final question = navigator.suggestFollowUpQuestion('quantum_physics');
      expect(question, contains('Erzähl mir mehr darüber'));
    });
  });
}
