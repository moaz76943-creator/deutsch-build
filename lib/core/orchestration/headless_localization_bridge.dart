import 'dart:async';

import 'event_bus.dart';
import 'orchestration_kernel.dart';
import 'orchestration_models.dart';
import 'service_container.dart';

final class HeadlessLocalizationBridge {
  HeadlessLocalizationBridge._({
    required AgentEventBus eventBus,
    required OrchestrationKernel kernel,
    required AgentEndpoint endpoint,
  })  : _eventBus = eventBus,
        _kernel = kernel,
        _endpoint = endpoint {
    _subscription = endpoint
        .events(AgentTopics.localizationChangeRequested)
        .listen(_handleRequest);
  }

  static HeadlessLocalizationBridge start({
    AgentEventBus? eventBus,
  }) {
    final bus = eventBus ?? AgentEventBus();
    final kernel = OrchestrationKernel(
      eventBus: bus,
      services: ServiceContainer(),
    );
    final endpoint = kernel.connect(
      AgentDescriptor(
        id: 'headless.localization-bridge',
        role: AgentRole.localization,
        subscriptions: const <String>{
          AgentTopics.localizationChangeRequested,
        },
        observesTargetedEvents: true,
      ),
    );
    return HeadlessLocalizationBridge._(
      eventBus: bus,
      kernel: kernel,
      endpoint: endpoint,
    );
  }

  final AgentEventBus _eventBus;
  final OrchestrationKernel _kernel;
  final AgentEndpoint _endpoint;

  late final StreamSubscription<AgentEvent> _subscription;
  int _revision = 0;
  bool _closed = false;

  bool get isClosed => _closed;

  void _handleRequest(AgentEvent event) {
    if (_closed) return;

    final source = _language(
      event.payload['sourceLocale'],
      'sourceLocale',
    );
    final target = _language(
      event.payload['targetLocale'],
      'targetLocale',
    );
    if (source == target) {
      throw const FormatException(
        'Headless localization source and target must differ.',
      );
    }

    _revision += 1;
    _endpoint.publish(
      topic: AgentTopics.localizationChanged,
      targetRoles: const <AgentRole>{
        AgentRole.polyglot,
        AgentRole.routing,
        AgentRole.cards,
        AgentRole.design,
        AgentRole.task,
      },
      context: event.context,
      payload: <String, Object?>{
        'userLocale': source,
        'sourceLocale': source,
        'targetLocale': target,
        'revision': _revision,
        'direction': _isRtl(source) ? 'rtl' : 'ltr',
      },
    );
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _subscription.cancel();
    await _kernel.close();
    if (_eventBus.isClosed) return;
  }
}

String _language(Object? value, String field) {
  if (value is! String) {
    throw FormatException('$field must be a language tag.');
  }
  final normalized = value.trim().replaceAll('_', '-').toLowerCase();
  if (!RegExp(r'^[a-z]{2,8}(?:-[a-z0-9]{1,8})*$').hasMatch(normalized)) {
    throw FormatException('$field must be a valid language tag.');
  }
  return normalized;
}

bool _isRtl(String languageTag) {
  final code = languageTag.split('-').first;
  return const <String>{'ar', 'fa', 'ur'}.contains(code);
}
