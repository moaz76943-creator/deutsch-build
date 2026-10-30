import 'package:test/test.dart';
import 'package:deutsch_build/src/core/dialogue/conversational_eloquence_assistant.dart';

void main() {
  group('ConversationalEloquenceAssistant Tests', () {
    const assistant = ConversationalEloquenceAssistant();

    test('Suggests idiomatic collocation "Sport treiben" over "Sport machen"', () {
      final suggestions = assistant.suggestEloquenceAlternatives('Ich mache jeden Tag Sport.');

      expect(suggestions.isNotEmpty, isTrue);
      final s = suggestions.firstWhere((s) => s.category == EloquenceCategory.idiomaticCollocation);
      expect(s.suggestedAlternative, equals('Sport treiben'));
      expect(s.targetCefrLevel, equals('B1'));
    });

    test('Elevates conversational register for "Ich will"', () {
      final suggestions = assistant.suggestEloquenceAlternatives('Ich will ein Ticket kaufen.');

      expect(suggestions.any((s) => s.category == EloquenceCategory.registerElevation), isTrue);
      final s = suggestions.firstWhere((s) => s.category == EloquenceCategory.registerElevation);
      expect(s.suggestedAlternative, contains('Ich würde gerne'));
    });

    test('Recommends descriptive adjective for "sehr gut"', () {
      final suggestions = assistant.suggestEloquenceAlternatives('Das Essen schmeckt sehr gut.');

      expect(suggestions.any((s) => s.category == EloquenceCategory.lexicalNuance), isTrue);
      final s = suggestions.firstWhere((s) => s.category == EloquenceCategory.lexicalNuance);
      expect(s.suggestedAlternative, contains('ausgezeichnet'));
    });
  });
}
