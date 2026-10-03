enum DialogueSpeaker { learner, interlocutor }

final class DialogueTurn {
  const DialogueTurn({
    required this.id,
    required this.speaker,
    required this.germanText,
    required this.arabicTranslation,
    this.audioConceptId,
  });

  final String id;
  final DialogueSpeaker speaker;
  final String germanText;
  final String arabicTranslation;
  final String? audioConceptId;
}

final class DialogueChoice {
  const DialogueChoice({
    required this.id,
    required this.germanText,
    required this.arabicTranslation,
    required this.nextNodeId,
    required this.points,
  }) : assert(points >= 0);

  final String id;
  final String germanText;
  final String arabicTranslation;
  final String nextNodeId;
  final int points;
}

final class DialogueNode {
  const DialogueNode({
    required this.id,
    required this.turn,
    this.choices = const <DialogueChoice>[],
  });

  final String id;
  final DialogueTurn turn;
  final List<DialogueChoice> choices;

  bool get isTerminal => choices.isEmpty;

  int get maxChoicePoints {
    if (choices.isEmpty) return 0;
    return choices
        .map((choice) => choice.points)
        .reduce((current, value) => current > value ? current : value);
  }
}

final class DialogueScenario {
  DialogueScenario({
    required this.id,
    required this.titleGerman,
    required this.titleArabic,
    required this.startNodeId,
    required Map<String, DialogueNode> nodes,
  }) : nodes = Map<String, DialogueNode>.unmodifiable(nodes) {
    _validate();
  }

  final String id;
  final String titleGerman;
  final String titleArabic;
  final String startNodeId;
  final Map<String, DialogueNode> nodes;

  DialogueNode get startNode => node(startNodeId);

  DialogueNode node(String nodeId) {
    final result = nodes[nodeId];
    if (result == null) {
      throw DialogueDefinitionException(
        'Scenario $id references missing node $nodeId.',
      );
    }
    return result;
  }

  void _validate() {
    if (id.trim().isEmpty) {
      throw const DialogueDefinitionException('Scenario id must not be empty.');
    }
    if (!nodes.containsKey(startNodeId)) {
      throw DialogueDefinitionException(
        'Scenario $id has missing start node $startNodeId.',
      );
    }
    for (final entry in nodes.entries) {
      if (entry.key != entry.value.id) {
        throw DialogueDefinitionException(
          'Scenario $id node key ${entry.key} does not match ${entry.value.id}.',
        );
      }
      if (entry.value.turn.id.trim().isEmpty ||
          entry.value.turn.germanText.trim().isEmpty) {
        throw DialogueDefinitionException(
          'Scenario $id node ${entry.key} has an invalid turn.',
        );
      }
      final choiceIds = <String>{};
      for (final choice in entry.value.choices) {
        if (!choiceIds.add(choice.id)) {
          throw DialogueDefinitionException(
            'Scenario $id node ${entry.key} repeats choice ${choice.id}.',
          );
        }
        if (!nodes.containsKey(choice.nextNodeId)) {
          throw DialogueDefinitionException(
            'Scenario $id choice ${choice.id} references missing node '
            '${choice.nextNodeId}.',
          );
        }
      }
    }
  }
}

final class DialogueDefinitionException implements Exception {
  const DialogueDefinitionException(this.message);

  final String message;

  @override
  String toString() => 'DialogueDefinitionException: $message';
}
