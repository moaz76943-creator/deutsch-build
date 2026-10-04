import 'dart:async';

import '../../core/curriculum/advanced_vocabulary.dart';
import '../../core/orchestration/orchestration.dart';
import 'life_curriculum_catalog.dart';

final class VocabularyProjectionDeckRegistry {
  VocabularyProjectionDeckRegistry(
    Map<String, List<VocabularyFlashcardProjection>> decks,
  ) : _decks = Map<String, List<VocabularyFlashcardProjection>>.unmodifiable(
          <String, List<VocabularyFlashcardProjection>>{
            for (final entry in decks.entries)
              entry.key.trim(): List<VocabularyFlashcardProjection>.unmodifiable(
                entry.value,
              ),
          },
        ) {
    if (_decks.isEmpty) {
      throw ArgumentError('At least one vocabulary projection deck is required.');
    }
    if (_decks.keys.any((key) => key.isEmpty)) {
      throw ArgumentError('Vocabulary deck ids must not be empty.');
    }
  }

  final Map<String, List<VocabularyFlashcardProjection>> _decks;

  bool contains(String deckId) => _decks.containsKey(deckId.trim());

  List<VocabularyFlashcardProjection> require(String deckId) {
    final deck = _decks[deckId.trim()];
    if (deck == null) {
      throw StateError('Unknown vocabulary deck: $deckId');
    }
    return deck;
  }
}

final class Phase3DesignProfile {
  const Phase3DesignProfile({
    required this.navigation,
    required this.flashcardMode,
    required this.direction,
    required this.density,
  });

  final String navigation;
  final String flashcardMode;
  final String direction;
  final String density;
}

final class Phase3RouteSelection {
  const Phase3RouteSelection({
    required this.featureKey,
    required this.curriculumTaskId,
  });

  final String featureKey;
  final String curriculumTaskId;
}

final class Phase3CardsReady {
  const Phase3CardsReady({
    required this.deckId,
    required this.cardCount,
  });

  final String deckId;
  final int cardCount;
}

final class Phase3AgentRuntime {
  Phase3AgentRuntime._({
    required AgentEventBus eventBus,
    required OrchestrationKernel kernel,
    required AgentEndpoint taskEndpoint,
    required _DesignProductionAgent designAgent,
    required _RoutingProductionAgent routingAgent,
    required _CardsProductionAgent cardsAgent,
  })  : _eventBus = eventBus,
        _kernel = kernel,
        _taskEndpoint = taskEndpoint,
        _designAgent = designAgent,
        _routingAgent = routingAgent,
        _cardsAgent = cardsAgent;

  factory Phase3AgentRuntime.start({
    required LifeCurriculumCatalog catalog,
    required VocabularyProjectionDeckRegistry decks,
  }) {
    final eventBus = AgentEventBus();
    final services = ServiceContainer();
    services.registerSingleton(_catalogToken, catalog);
    services.registerSingleton(_decksToken, decks);

    final kernel = OrchestrationKernel(
      eventBus: eventBus,
      services: services,
    );
    final taskEndpoint = kernel.connect(
      AgentDescriptor(
        id: 'phase3.task-ui',
        role: AgentRole.task,
        subscriptions: <String>{
          AgentTopics.routeSelected,
          AgentTopics.contextUpdated,
        },
      ),
    );
    final designEndpoint = kernel.connect(
      AgentDescriptor(
        id: 'phase3.design-agent',
        role: AgentRole.design,
        subscriptions: <String>{AgentTopics.designRequest},
      ),
    );
    final routingEndpoint = kernel.connect(
      AgentDescriptor(
        id: 'phase3.routing-agent',
        role: AgentRole.routing,
        subscriptions: <String>{AgentTopics.routeRequest},
      ),
    );
    final cardsEndpoint = kernel.connect(
      AgentDescriptor(
        id: 'phase3.cards-agent',
        role: AgentRole.cards,
        subscriptions: <String>{AgentTopics.cardsRequest},
      ),
    );

    return Phase3AgentRuntime._(
      eventBus: eventBus,
      kernel: kernel,
      taskEndpoint: taskEndpoint,
      designAgent: _DesignProductionAgent(designEndpoint),
      routingAgent: _RoutingProductionAgent(routingEndpoint),
      cardsAgent: _CardsProductionAgent(cardsEndpoint),
    );
  }

  static final ServiceToken<LifeCurriculumCatalog> _catalogToken =
      ServiceToken<LifeCurriculumCatalog>('phase3.catalog');
  static final ServiceToken<VocabularyProjectionDeckRegistry> _decksToken =
      ServiceToken<VocabularyProjectionDeckRegistry>('phase3.decks');

  final AgentEventBus _eventBus;
  final OrchestrationKernel _kernel;
  final AgentEndpoint _taskEndpoint;
  final _DesignProductionAgent _designAgent;
  final _RoutingProductionAgent _routingAgent;
  final _CardsProductionAgent _cardsAgent;

  int _requestSequence = 0;
  bool _closed = false;

  bool get isClosed => _closed;
  int get publishedEventCount => _eventBus.publishedCount;

  Future<Phase3DesignProfile> requestDesign() async {
    _ensureOpen();
    final correlationId = _nextCorrelation('design');
    final response = _waitForContext(correlationId, 'design.ready');
    _taskEndpoint.publish(
      topic: AgentTopics.designRequest,
      targetRoles: const <AgentRole>{AgentRole.design},
      context: AgentContextSnapshot.empty(correlationId),
      payload: const <String, Object?>{'surface': 'phase3-shell'},
    );
    final event = await response;
    return Phase3DesignProfile(
      navigation: _stringPayload(event, 'navigation'),
      flashcardMode: _stringPayload(event, 'flashcardMode'),
      direction: _stringPayload(event, 'direction'),
      density: _stringPayload(event, 'density'),
    );
  }

  Future<Phase3RouteSelection> requestRoute(String featureKey) async {
    _ensureOpen();
    final correlationId = _nextCorrelation('route');
    final response = _taskEndpoint
        .events(AgentTopics.routeSelected)
        .firstWhere(
          (event) => event.context.correlationId == correlationId,
        )
        .timeout(const Duration(seconds: 2));

    _taskEndpoint.publish(
      topic: AgentTopics.routeRequest,
      targetRoles: const <AgentRole>{AgentRole.routing},
      context: AgentContextSnapshot.empty(correlationId),
      payload: <String, Object?>{'featureKey': featureKey.trim()},
    );

    final event = await response;
    if (event.payload['ok'] != true) {
      throw StateError(
        event.payload['message'] as String? ?? 'Route request was rejected.',
      );
    }
    return Phase3RouteSelection(
      featureKey: _stringPayload(event, 'featureKey'),
      curriculumTaskId: _stringPayload(event, 'curriculumTaskId'),
    );
  }

  Future<Phase3CardsReady> requestCards(String deckId) async {
    _ensureOpen();
    final correlationId = _nextCorrelation('cards');
    final response = _taskEndpoint
        .events(AgentTopics.contextUpdated)
        .firstWhere(
          (event) => event.context.correlationId == correlationId,
        )
        .timeout(const Duration(seconds: 2));

    _taskEndpoint.publish(
      topic: AgentTopics.cardsRequest,
      targetRoles: const <AgentRole>{AgentRole.cards},
      context: AgentContextSnapshot.empty(correlationId),
      payload: <String, Object?>{'deckId': deckId.trim()},
    );

    final event = await response;
    if (event.payload['kind'] == 'cards.error') {
      throw StateError(
        event.payload['message'] as String? ?? 'Card request was rejected.',
      );
    }
    if (event.payload['kind'] != 'cards.ready') {
      throw StateError('Unexpected Cards Agent response.');
    }
    return Phase3CardsReady(
      deckId: _stringPayload(event, 'deckId'),
      cardCount: (event.payload['cardCount'] as num).toInt(),
    );
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _designAgent.close();
    await _routingAgent.close();
    await _cardsAgent.close();
    await _kernel.close();
  }

  Future<AgentEvent> _waitForContext(
    String correlationId,
    String kind,
  ) =>
      _taskEndpoint
          .events(AgentTopics.contextUpdated)
          .firstWhere(
            (event) =>
                event.context.correlationId == correlationId &&
                event.payload['kind'] == kind,
          )
          .timeout(const Duration(seconds: 2));

  String _nextCorrelation(String purpose) {
    _requestSequence += 1;
    return 'phase3.$purpose.$_requestSequence';
  }

  void _ensureOpen() {
    if (_closed) {
      throw StateError('Phase3AgentRuntime is closed.');
    }
  }

  static String _stringPayload(AgentEvent event, String key) {
    final value = event.payload[key];
    if (value is! String || value.isEmpty) {
      throw StateError('Agent response is missing $key.');
    }
    return value;
  }
}

final class _DesignProductionAgent {
  _DesignProductionAgent(this.endpoint) {
    _subscription = endpoint
        .events(AgentTopics.designRequest)
        .listen(_handle);
  }

  final AgentEndpoint endpoint;
  late final StreamSubscription<AgentEvent> _subscription;

  void _handle(AgentEvent event) {
    endpoint.publish(
      topic: AgentTopics.contextUpdated,
      targetRoles: const <AgentRole>{AgentRole.task},
      context: event.context,
      payload: const <String, Object?>{
        'kind': 'design.ready',
        'navigation': 'bottom',
        'flashcardMode': '3d',
        'direction': 'rtl',
        'density': 'comfortable',
      },
    );
  }

  Future<void> close() => _subscription.cancel();
}

final class _RoutingProductionAgent {
  _RoutingProductionAgent(this.endpoint)
      : _catalog = endpoint.resolve(Phase3AgentRuntime._catalogToken) {
    _subscription = endpoint
        .events(AgentTopics.routeRequest)
        .listen(_handle);
  }

  final AgentEndpoint endpoint;
  final LifeCurriculumCatalog _catalog;
  late final StreamSubscription<AgentEvent> _subscription;

  void _handle(AgentEvent event) {
    final featureKey = event.payload['featureKey'];
    final link = featureKey is String ? _catalog.find(featureKey) : null;

    endpoint.publish(
      topic: AgentTopics.routeSelected,
      targetRoles: const <AgentRole>{AgentRole.task},
      context: event.context,
      payload: link == null
          ? <String, Object?>{
              'ok': false,
              'message': 'Unknown life feature route.',
            }
          : <String, Object?>{
              'ok': true,
              'featureKey': link.featureKey,
              'curriculumTaskId': link.curriculumTaskId,
            },
    );
  }

  Future<void> close() => _subscription.cancel();
}

final class _CardsProductionAgent {
  _CardsProductionAgent(this.endpoint)
      : _decks = endpoint.resolve(Phase3AgentRuntime._decksToken) {
    _subscription = endpoint
        .events(AgentTopics.cardsRequest)
        .listen(_handle);
  }

  final AgentEndpoint endpoint;
  final VocabularyProjectionDeckRegistry _decks;
  late final StreamSubscription<AgentEvent> _subscription;

  void _handle(AgentEvent event) {
    final deckId = event.payload['deckId'];
    if (deckId is! String || !_decks.contains(deckId)) {
      endpoint.publish(
        topic: AgentTopics.contextUpdated,
        targetRoles: const <AgentRole>{AgentRole.task},
        context: event.context,
        payload: const <String, Object?>{
          'kind': 'cards.error',
          'message': 'Unknown vocabulary deck.',
        },
      );
      return;
    }

    final deck = _decks.require(deckId);
    endpoint.publish(
      topic: AgentTopics.contextUpdated,
      targetRoles: const <AgentRole>{AgentRole.task},
      context: event.context,
      payload: <String, Object?>{
        'kind': 'cards.ready',
        'deckId': deckId,
        'cardCount': deck.length,
      },
    );
  }

  Future<void> close() => _subscription.cancel();
}
