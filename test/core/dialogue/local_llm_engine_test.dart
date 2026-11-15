import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/dialogue/local_llm_engine.dart';

void main() {
  group('LocalLlmEngine Tests', () {
    test('Model profile confirms mobile memory footprint under 160MB', () {
      expect(LlmModelProfile.gemma2Mobile.requiredMemoryMb, lessThan(160.0));
      expect(LlmModelProfile.qwen25Mobile.requiredMemoryMb, lessThan(120.0));
    });

    test('Prompt formatting adheres to ChatML/Gemma token markers', () {
      final engine = LocalLlmEngine();
      final history = [
        DialogueMessage(role: DialogueRole.system, content: 'Du bist Kellner.'),
        DialogueMessage(role: DialogueRole.user, content: 'Ein Wasser bitte.'),
      ];

      final prompt = engine.formatPrompt(history);
      expect(prompt, contains('<start_of_turn>system\nDu bist Kellner.<end_of_turn>'));
      expect(prompt, contains('<start_of_turn>user\nEin Wasser bitte.<end_of_turn>'));
      expect(prompt.endsWith('<start_of_turn>model\n'), isTrue);
    });

    test('Streams sovereign tokens sequentially without network', () async {
      final engine = LocalLlmEngine();
      final history = [
        DialogueMessage(role: DialogueRole.user, content: 'Hallo, Guten Tag!'),
      ];

      final tokens = await engine.generateTokenStream(history).toList();
      expect(tokens.isNotEmpty, isTrue);

      final fullResponse = tokens.join();
      expect(fullResponse, contains('Guten Tag!'));
    });
  });
}
