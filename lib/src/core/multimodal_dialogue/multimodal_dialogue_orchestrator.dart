/// Current state of conversational exchange.
enum DialoguePhase {
  listening,
  processing,
  speaking,
  interrupted,
}

/// Orchestrates multimodal sensory inputs (voice frames, camera scenes, text) into conversational actions.
class MultimodalDialogueOrchestrator {
  DialoguePhase _currentPhase = DialoguePhase.listening;
  final List<String> _dialogueHistory = [];
  bool _isCameraContextAttached = false;

  DialoguePhase get currentPhase => _currentPhase;
  int get turnCount => _dialogueHistory.length;
  bool get hasCameraContext => _isCameraContextAttached;

  /// Attaches visual scene context from offline camera feed.
  void attachVisualContext(String sceneDescription) {
    _isCameraContextAttached = sceneDescription.trim().isNotEmpty;
  }

  /// Processes user turn and transitions phase state.
  Map<String, dynamic> processUserTurn(String utterance) {
    if (utterance.trim().isEmpty) {
      return {'status': 'ignored', 'phase': _currentPhase.name};
    }

    _currentPhase = DialoguePhase.processing;
    _dialogueHistory.add('User: $utterance');

    // Simulate response generation
    _currentPhase = DialoguePhase.speaking;
    final botResponse = 'Verstanden. Wir sprechen über: $utterance';
    _dialogueHistory.add('Bot: $botResponse');

    return {
      'status': 'success',
      'phase': _currentPhase.name,
      'response': botResponse,
      'visualGrounded': _isCameraContextAttached,
    };
  }

  /// Handles user barge-in / speech overlap during bot speech.
  void handleInterruption() {
    if (_currentPhase == DialoguePhase.speaking) {
      _currentPhase = DialoguePhase.interrupted;
      // Immediately yield audio channel
      _currentPhase = DialoguePhase.listening;
    }
  }

  /// Resets dialogue session.
  void reset() {
    _currentPhase = DialoguePhase.listening;
    _dialogueHistory.clear();
    _isCameraContextAttached = false;
  }
}
