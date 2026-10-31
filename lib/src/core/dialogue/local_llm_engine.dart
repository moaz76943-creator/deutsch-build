import 'dart:async';

enum LlmQuantization {
  q4KM, // 4-bit medium (balanced speed/quality)
  q3KS, // 3-bit small (low-RAM budget)
  q80,  // 8-bit precision
}

enum DialogueRole {
  system,
  user,
  assistant,
}

class DialogueMessage {
  final DialogueRole role;
  final String content;
  final DateTime timestamp;
  final int estimatedTokens;

  DialogueMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
    int? estimatedTokens,
  })  : timestamp = timestamp ?? DateTime.now(),
        estimatedTokens = estimatedTokens ?? (content.length / 3.8).ceil();

  Map<String, dynamic> toJson() => {
    'role': role.name,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'estimatedTokens': estimatedTokens,
  };
}

class LlmModelProfile {
  final String modelName;
  final String architecture;
  final LlmQuantization quantization;
  final int maxContextLength;
  final double requiredMemoryMb;

  const LlmModelProfile({
    required this.modelName,
    required this.architecture,
    required this.quantization,
    required this.maxContextLength,
    required this.requiredMemoryMb,
  });

  static const LlmModelProfile gemma2Mobile = LlmModelProfile(
    modelName: 'Gemma-2-2B-IT-Mobile',
    architecture: 'gemma2',
    quantization: LlmQuantization.q4KM,
    maxContextLength: 2048,
    requiredMemoryMb: 145.0,
  );

  static const LlmModelProfile qwen25Mobile = LlmModelProfile(
    modelName: 'Qwen-2.5-1.5B-Instruct',
    architecture: 'qwen2',
    quantization: LlmQuantization.q4KM,
    maxContextLength: 2048,
    requiredMemoryMb: 110.0,
  );
}

class LocalLlmEngine {
  final LlmModelProfile profile;
  bool _isLoaded = false;

  LocalLlmEngine({this.profile = LlmModelProfile.gemma2Mobile});

  bool get isLoaded => _isLoaded;

  Future<void> loadModel() async {
    // Simulates local mmap and GGML tensor memory allocation
    await Future.delayed(const Duration(milliseconds: 20));
    _isLoaded = true;
  }

  /// Formats dialogue turns into standard ChatML / Gemma prompt format.
  String formatPrompt(List<DialogueMessage> history) {
    final buffer = StringBuffer();
    for (final msg in history) {
      switch (msg.role) {
        case DialogueRole.system:
          buffer.writeln('<start_of_turn>system\n${msg.content}<end_of_turn>');
          break;
        case DialogueRole.user:
          buffer.writeln('<start_of_turn>user\n${msg.content}<end_of_turn>');
          break;
        case DialogueRole.assistant:
          buffer.writeln('<start_of_turn>model\n${msg.content}<end_of_turn>');
          break;
      }
    }
    buffer.write('<start_of_turn>model\n');
    return buffer.toString();
  }

  /// Generates streaming response tokens with zero external cloud calls.
  Stream<String> generateTokenStream(List<DialogueMessage> history, {double temperature = 0.7}) async* {
    if (!_isLoaded) {
      await loadModel();
    }

    final userMessage = history.lastWhere((m) => m.role == DialogueRole.user, orElse: () => DialogueMessage(role: DialogueRole.user, content: 'Hallo'));
    final tokens = _generateSovereignResponseTokens(userMessage.content);

    for (final token in tokens) {
      await Future.delayed(const Duration(milliseconds: 5));
      yield token;
    }
  }

  List<String> _generateSovereignResponseTokens(String userPrompt) {
    final lower = userPrompt.toLowerCase();
    if (lower.contains('hallo') || lower.contains('guten tag')) {
      return ['Guten ', 'Tag! ', 'Wie ', 'kann ', 'ich ', 'Ihnen ', 'helfen?'];
    } else if (lower.contains('wasser') || lower.contains('speisekarte')) {
      return ['Sehr ', 'gerne! ', 'Hier ', 'ist ', 'die ', 'Speisekarte ', 'für ', 'Sie.'];
    } else {
      return ['Ich ', 'verstehe. ', 'Möchten ', 'Sie ', 'noch ', 'etwas ', 'dazu ', 'probieren?'];
    }
  }
}
