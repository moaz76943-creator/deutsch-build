import 'dart:async';

import '../orchestration/orchestration.dart';

enum RecoveryMode {
  safeSection,
  safeShell,
}

final class RecoveryDirective {
  const RecoveryDirective({
    required this.mode,
    required this.context,
    required this.userMessage,
    required this.occurrenceCount,
    required this.fatal,
  });

  final RecoveryMode mode;
  final String context;
  final String userMessage;
  final int occurrenceCount;
  final bool fatal;

  static RecoveryDirective fromEvent(AgentEvent event) {
    final rawMode = event.payload['mode'];
    final mode = rawMode == RecoveryMode.safeShell.name
        ? RecoveryMode.safeShell
        : RecoveryMode.safeSection;
    return RecoveryDirective(
      mode: mode,
      context: _safeText(
        event.payload['context'],
        fallback: 'application',
        maxLength: 120,
      ),
      userMessage: _safeText(
        event.payload['userMessage'],
        fallback: 'تم نقل التطبيق إلى حالة آمنة.',
        maxLength: 240,
      ),
      occurrenceCount: _int(event.payload['occurrenceCount']).clamp(1, 1000000).toInt(),
      fatal: event.payload['fatal'] == true,
    );
  }
}

final class SysErrorRecoveryFallback {
  SysErrorRecoveryFallback._(this.endpoint) {
    _subscription = endpoint
        .events(AgentTopics.systemError)
        .listen(_handle);
  }

  factory SysErrorRecoveryFallback.start({
    required AgentEndpoint endpoint,
  }) =>
      SysErrorRecoveryFallback._(endpoint);

  static const int escalationThreshold = 3;
  static const int maxTrackedContexts = 64;

  final AgentEndpoint endpoint;
  final Map<String, int> _occurrences = <String, int>{};
  late final StreamSubscription<AgentEvent> _subscription;
  bool _closed = false;

  bool get isClosed => _closed;

  void _handle(AgentEvent event) {
    if (_closed) return;

    final context = _safeText(
      event.payload['context'],
      fallback: 'application',
      maxLength: 120,
    );
    final fatal = event.payload['fatal'] == true;
    final count = (_occurrences[context] ?? 0) + 1;
    _occurrences[context] = count;
    _boundOccurrences();

    final mode = fatal || count >= escalationThreshold
        ? RecoveryMode.safeShell
        : RecoveryMode.safeSection;

    endpoint.publish(
      topic: AgentTopics.systemRecovery,
      targetRoles: const <AgentRole>{AgentRole.system},
      context: event.context,
      payload: <String, Object?>{
        'mode': mode.name,
        'context': context,
        'fatal': fatal,
        'occurrenceCount': count,
        'errorType': _safeText(
          event.payload['errorType'],
          fallback: 'Error',
          maxLength: 100,
        ),
        'userMessage': mode == RecoveryMode.safeShell
            ? 'تم تحويل التطبيق إلى الواجهة الآمنة لحماية الجلسة.'
            : 'تم عزل الجزء المتأثر ويمكن متابعة استخدام التطبيق بأمان.',
      },
    );
  }

  void _boundOccurrences() {
    if (_occurrences.length <= maxTrackedContexts) return;
    final keys = _occurrences.keys.toList(growable: false)..sort();
    final removeCount = _occurrences.length - maxTrackedContexts;
    for (final key in keys.take(removeCount)) {
      _occurrences.remove(key);
    }
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _subscription.cancel();
  }
}

String _safeText(
  Object? value, {
  required String fallback,
  required int maxLength,
}) {
  final text = value is String ? value.trim() : '';
  if (text.isEmpty) return fallback;
  return text.length <= maxLength ? text : text.substring(0, maxLength);
}

int _int(Object? value) => value is num ? value.toInt() : 1;
