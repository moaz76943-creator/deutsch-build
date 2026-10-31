import 'collaboration_models.dart';

final class AgentMessagingSystem {
  final Map<String, List<AgentMessage>> _mailboxes =
      <String, List<AgentMessage>>{};
  final Set<String> _seenIds = <String>{};

  bool send(AgentMessage message) {
    if (!_isValid(message)) return false;
    if (!_seenIds.add(message.id)) return false;

    final mailbox = _mailboxes.putIfAbsent(
      message.recipientId,
      () => <AgentMessage>[],
    );
    mailbox.add(message);
    mailbox.sort((a, b) {
      final byTime = a.createdAt.compareTo(b.createdAt);
      if (byTime != 0) return byTime;
      return a.id.compareTo(b.id);
    });
    return true;
  }

  List<AgentMessage> pendingFor(String recipientId) =>
      List<AgentMessage>.unmodifiable(
        _mailboxes[recipientId] ?? const <AgentMessage>[],
      );

  bool acknowledge({
    required String recipientId,
    required String messageId,
  }) {
    final mailbox = _mailboxes[recipientId];
    if (mailbox == null) return false;
    final index = mailbox.indexWhere((message) => message.id == messageId);
    if (index < 0) return false;
    mailbox.removeAt(index);
    if (mailbox.isEmpty) _mailboxes.remove(recipientId);
    return true;
  }

  int pendingCount(String recipientId) =>
      _mailboxes[recipientId]?.length ?? 0;

  bool hasSeen(String messageId) => _seenIds.contains(messageId);

  static bool _isValid(AgentMessage message) =>
      message.id.trim().isNotEmpty &&
      message.senderId.trim().isNotEmpty &&
      message.recipientId.trim().isNotEmpty &&
      message.topic.trim().isNotEmpty &&
      message.senderId != message.recipientId;
}
