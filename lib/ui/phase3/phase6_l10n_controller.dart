import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/curriculum/canonical_curriculum_50.dart';
import '../../core/curriculum/omni_directional_matrix.dart';
import '../../core/l10n/l10n.dart';
import '../../core/orchestration/orchestration.dart';
import 'phase3_ui_dictionaries.dart';

final class Phase6L10nController extends ChangeNotifier {
  Phase6L10nController._({
    required this.matrix,
    required DynamicL10nEngine engine,
    required AgentEventBus eventBus,
    required OrchestrationKernel kernel,
    required AgentEndpoint requester,
    required L10nEventBridge bridge,
    required LocalizationDesignRoutingObservers observers,
  })  : _engine = engine,
        _eventBus = eventBus,
        _kernel = kernel,
        _requester = requester,
        _bridge = bridge,
        _observers = observers,
        _pair = matrix.requirePair(
          engine.snapshot.sourceLocale.languageCode,
          engine.snapshot.targetLocale.languageCode,
        ),
        _plan = PairAwareCurriculumPlan.build(
          pair: matrix.requirePair(
            engine.snapshot.sourceLocale.languageCode,
            engine.snapshot.targetLocale.languageCode,
          ),
          tasks: CanonicalCurriculum50.tasks,
        ) {
    _designSubscription = _observers.designChanges.listen(_onDesignChange);
    _routingSubscription = _observers.routingChanges.listen(_onRoutingChange);
  }

  factory Phase6L10nController.standard() {
    final matrix = OmniDirectionalLearningMatrix.standard20();
    final engine = DynamicL10nEngine(
      initialState: LocalizationState.fromLanguageTags(
        userLanguageTag: 'ar',
        sourceLanguageTag: 'ar',
        targetLanguageTag: 'de',
      ),
      fallbackLanguageTag: 'en',
      dictionaries: Phase3UiDictionaries.build(),
    );
    final eventBus = AgentEventBus();
    final kernel = OrchestrationKernel(
      eventBus: eventBus,
      services: ServiceContainer(),
    );
    final localizationEndpoint = kernel.connect(
      AgentDescriptor(
        id: 'phase6.localization-runtime',
        role: AgentRole.localization,
        subscriptions: const <String>{
          AgentTopics.localizationChangeRequested,
        },
      ),
    );
    final observers = LocalizationDesignRoutingObservers.connect(kernel);
    final requester = kernel.connect(
      AgentDescriptor(
        id: 'phase6.ui-language-selector',
        role: AgentRole.task,
        subscriptions: const <String>{AgentTopics.contextUpdated},
      ),
    );
    final bridge = L10nEventBridge(
      engine: engine,
      endpoint: localizationEndpoint,
    );

    return Phase6L10nController._(
      matrix: matrix,
      engine: engine,
      eventBus: eventBus,
      kernel: kernel,
      requester: requester,
      bridge: bridge,
      observers: observers,
    );
  }

  final OmniDirectionalLearningMatrix matrix;
  final DynamicL10nEngine _engine;
  final AgentEventBus _eventBus;
  final OrchestrationKernel _kernel;
  final AgentEndpoint _requester;
  final L10nEventBridge _bridge;
  final LocalizationDesignRoutingObservers _observers;

  late final StreamSubscription<AgentLocalizationState> _designSubscription;
  late final StreamSubscription<AgentLocalizationState> _routingSubscription;

  DirectedLanguagePair _pair;
  PairAwareCurriculumPlan _plan;
  AgentLocalizationState? _designState;
  AgentLocalizationState? _routingState;
  int _requestSequence = 0;
  bool _closed = false;

  L10nRuntimeSnapshot get snapshot => _engine.snapshot;
  DirectedLanguagePair get pair => _pair;
  PairAwareCurriculumPlan get curriculumPlan => _plan;
  AgentLocalizationState? get designState => _designState;
  AgentLocalizationState? get routingState => _routingState;
  bool get isClosed => _closed;

  TextDirection get textDirection =>
      snapshot.isRtl ? TextDirection.rtl : TextDirection.ltr;

  List<LearningLanguageIdentity> get languages => matrix.languages;

  String text(
    String key, {
    Map<String, Object?> arguments = const <String, Object?>{},
  }) =>
      _engine.text(key, arguments: arguments);

  LearningLanguageIdentity language(String id) =>
      matrix.requireLanguage(id);

  String languageLabel(String id) {
    final item = language(id);
    return '${item.nativeName} · ${item.englishName}';
  }

  void requestSelection({
    required String userLanguageId,
    required String sourceLanguageId,
    required String targetLanguageId,
  }) {
    _ensureOpen();

    final user = matrix.requireLanguage(userLanguageId);
    final pair = matrix.requirePair(
      sourceLanguageId,
      targetLanguageId,
    );

    _requestSequence += 1;
    _requester.publish(
      topic: AgentTopics.localizationChangeRequested,
      targetRoles: const <AgentRole>{AgentRole.localization},
      context: AgentContextSnapshot.empty(
        'phase6.language-selection.$_requestSequence',
      ),
      payload: <String, Object?>{
        'userLocale': user.id,
        'sourceLocale': pair.source.id,
        'targetLocale': pair.target.id,
      },
    );
  }

  void _onDesignChange(AgentLocalizationState state) {
    if (_closed) return;
    _designState = state;
    notifyListeners();
  }

  void _onRoutingChange(AgentLocalizationState state) {
    if (_closed) return;
    _routingState = state;
    try {
      final nextPair = matrix.requirePair(
        state.sourceLocale,
        state.targetLocale,
      );
      _pair = nextPair;
      _plan = PairAwareCurriculumPlan.build(
        pair: nextPair,
        tasks: CanonicalCurriculum50.tasks,
      );
    } on ArgumentError {
      return;
    }
    notifyListeners();
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _designSubscription.cancel();
    await _routingSubscription.cancel();
    await _observers.close();
    await _bridge.close();
    await _kernel.close();
    await _engine.close();
  }

  @override
  void dispose() {
    unawaited(close());
    super.dispose();
  }

  void _ensureOpen() {
    if (_closed) {
      throw StateError('Phase6L10nController is closed.');
    }
    if (_eventBus.isClosed) {
      throw StateError('Phase6 localization EventBus facade is closed.');
    }
  }
}
