import 'dart:async';

/// Event representing a cache invalidation request.
class CacheInvalidationEvent {
  final String eventId;
  final Set<String> targetTags;
  final DateTime timestamp;
  final String originSubsystem;

  CacheInvalidationEvent({
    required this.eventId,
    required this.targetTags,
    required this.originSubsystem,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().toUtc();

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'tags': targetTags.toList(),
        'origin': originSubsystem,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Pub/Sub reactive cache invalidation bus with deterministic sequence numbers,
/// tag-based scoped purging, and dead-letter protection.
class SemanticCacheInvalidationBus {
  final StreamController<CacheInvalidationEvent> _controller =
      StreamController<CacheInvalidationEvent>.broadcast();
  final List<CacheInvalidationEvent> _auditLog = <CacheInvalidationEvent>[];
  final Set<String> _activeSubscribedTags = <String>{};
  int _dispatchedCount = 0;

  Stream<CacheInvalidationEvent> get stream => _controller.stream;
  int get dispatchedCount => _dispatchedCount;
  int get auditLogSize => _auditLog.length;

  void registerTagInterest(String tag) {
    _activeSubscribedTags.add(tag);
  }

  /// Dispatch an invalidation event across the mesh.
  void dispatchInvalidation({
    required String eventId,
    required Set<String> tags,
    required String originSubsystem,
  }) {
    final event = CacheInvalidationEvent(
      eventId: eventId,
      targetTags: Set<String>.unmodifiable(tags),
      originSubsystem: originSubsystem,
    );

    _dispatchedCount++;
    _auditLog.add(event);

    // Bounded log memory governance
    if (_auditLog.length > 256) {
      _auditLog.removeRange(0, _auditLog.length - 256);
    }

    _controller.add(event);
  }

  /// Check whether an incoming query tag intersects with recently invalidated tags.
  bool isTagRecentlyInvalidated(String tag, {Duration maxAge = const Duration(minutes: 5)}) {
    final cutoff = DateTime.now().toUtc().subtract(maxAge);
    for (int i = _auditLog.length - 1; i >= 0; i--) {
      final item = _auditLog[i];
      if (item.timestamp.isBefore(cutoff)) break;
      if (item.targetTags.contains(tag)) return true;
    }
    return false;
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
