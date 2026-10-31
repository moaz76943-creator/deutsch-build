import 'dart:async';

import 'orchestration_kernel.dart';
import 'orchestration_models.dart';

final class AgentLocalizationState {
  AgentLocalizationState({
    required this.revision,
    required this.userLocale,
    required this.sourceLocale,
    required this.targetLocale,
    required this.fallbackLocale,
    required this.direction,
    required this.isRtl,
    required List<String> loadedLocales,
  }) : loadedLocales = List<String>.unmodifiable(loadedLocales) {
    if (revision < 0) {
      throw ArgumentError.value(revision, 'revision', 'must be non-negative');
    }
    if (direction != 'ltr' && direction != 'rtl') {
      throw FormatException('Unsupported localization direction: $direction');
    }
  }

  final int revision;
  final String userLocale;
  final String sourceLocale;
  final String targetLocale;
  final String fallbackLocale;
  final String direction;
  final bool isRtl;
  final List<String> loadedLocales;

  static AgentLocalizationState fromEvent(AgentEvent event) {
    if (event.topic != AgentTopics.localizationChanged) {
      throw ArgumentError.value(
        event.topic,
        'event.topic',
        'Expected localization.changed.',
      );
    }
    return AgentLocalizationState(
      revision: _int(event.payload['revision'], 'revision'),
      userLocale: _text(event.payload['userLocale'], 'userLocale'),
      sourceLocale: _text(event.payload['sourceLocale'], 'sourceLocale'),
      targetLocale: _text(event.payload['targetLocale'], 'targetLocale'),
      fallbackLocale:
          _text(event.payload['fallbackLocale'], 'fallbackLocale'),
      direction: _text(event.payload['direction'], 'direction'),
      isRtl: _bool(event.payload['isRtl'], 'isRtl'),
      loadedLocales: _stringList(
        event.payload['loadedLocales'],
        'loadedLocales',
      ),
    );
  }
}

final class LocalizationDesignRoutingObservers {
  LocalizationDesignRoutingObservers._({
    required _LocalizationRoleObserver design,
    required _LocalizationRoleObserver routing,
  })  : _design = design,
        _routing = routing;

  factory LocalizationDesignRoutingObservers.connect(
    OrchestrationKernel kernel,
  ) {
    final designEndpoint = kernel.connect(
      AgentDescriptor(
        id: 'phase6.design-l10n-observer',
        role: AgentRole.design,
        subscriptions: const <String>{
          AgentTopics.localizationChanged,
        },
      ),
    );
    final routingEndpoint = kernel.connect(
      AgentDescriptor(
        id: 'phase6.routing-l10n-observer',
        role: AgentRole.routing,
        subscriptions: const <String>{
          AgentTopics.localizationChanged,
        },
      ),
    );

    return LocalizationDesignRoutingObservers._(
      design: _LocalizationRoleObserver(designEndpoint),
      routing: _LocalizationRoleObserver(routingEndpoint),
    );
  }

  final _LocalizationRoleObserver _design;
  final _LocalizationRoleObserver _routing;

  Stream<AgentLocalizationState> get designChanges => _design.changes;
  Stream<AgentLocalizationState> get routingChanges => _routing.changes;

  AgentLocalizationState? get latestDesign => _design.latest;
  AgentLocalizationState? get latestRouting => _routing.latest;

  Future<void> close() async {
    await _design.close();
    await _routing.close();
  }
}

final class _LocalizationRoleObserver {
  _LocalizationRoleObserver(this.endpoint) {
    if (endpoint.descriptor.role != AgentRole.design &&
        endpoint.descriptor.role != AgentRole.routing) {
      throw ArgumentError(
        'Localization observer endpoint must be Design or Routing role.',
      );
    }
    _subscription = endpoint
        .events(AgentTopics.localizationChanged)
        .listen(_accept);
  }

  final AgentEndpoint endpoint;
  final StreamController<AgentLocalizationState> _controller =
      StreamController<AgentLocalizationState>.broadcast(sync: true);

  late final StreamSubscription<AgentEvent> _subscription;
  AgentLocalizationState? _latest;
  bool _closed = false;

  Stream<AgentLocalizationState> get changes => _controller.stream;
  AgentLocalizationState? get latest => _latest;

  void _accept(AgentEvent event) {
    if (_closed) return;
    try {
      final state = AgentLocalizationState.fromEvent(event);
      _latest = state;
      _controller.add(state);
    } on Object {
      return;
    }
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _subscription.cancel();
    await _controller.close();
  }
}

String _text(Object? value, String field) {
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$field must be a non-empty string.');
  }
  return value.trim();
}

int _int(Object? value, String field) {
  if (value is! num) {
    throw FormatException('$field must be numeric.');
  }
  return value.toInt();
}

bool _bool(Object? value, String field) {
  if (value is! bool) {
    throw FormatException('$field must be boolean.');
  }
  return value;
}

List<String> _stringList(Object? value, String field) {
  if (value is! List) {
    throw FormatException('$field must be a list.');
  }
  final result = <String>[];
  for (final item in value) {
    if (item is! String || item.trim().isEmpty) {
      throw FormatException('$field must contain non-empty strings.');
    }
    result.add(item.trim());
  }
  return List<String>.unmodifiable(result);
}
