import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../core/agents/polyglot_agent_models.dart';
import '../../core/agents/sys_error_recovery_fallback.dart';
import '../../core/agents/system_agent_runtime.dart';
import '../../core/storage/offline_progress_service.dart';

final class EpochUIValue<T> {
  const EpochUIValue({
    required this.epoch,
    required this.value,
  });

  final int epoch;
  final T value;
}

abstract interface class AgentUIRuntimePort {
  int get pairEpoch;
  OfflineProgressSnapshot get progressSnapshot;
  PolyglotMatrixState? get matrixState;

  Stream<EpochUIValue<OfflineProgressSnapshot>> get progressSignals;
  Stream<EpochUIValue<PolyglotMatrixState>> get matrixSignals;
  Stream<EpochUIValue<RecoveryDirective>> get recoverySignals;

  void requestLearningPair({
    required String sourceLanguageTag,
    required String targetLanguageTag,
  });
}

final class AgentUIState {
  const AgentUIState({
    required this.pairEpoch,
    required this.progress,
    required this.matrix,
    required this.recovery,
  });

  final int pairEpoch;
  final OfflineProgressSnapshot progress;
  final PolyglotMatrixState? matrix;
  final RecoveryDirective? recovery;

  AgentUIState copyWith({
    int? pairEpoch,
    OfflineProgressSnapshot? progress,
    PolyglotMatrixState? matrix,
    bool clearMatrix = false,
    RecoveryDirective? recovery,
    bool clearRecovery = false,
  }) =>
      AgentUIState(
        pairEpoch: pairEpoch ?? this.pairEpoch,
        progress: progress ?? this.progress,
        matrix: clearMatrix ? null : matrix ?? this.matrix,
        recovery: clearRecovery ? null : recovery ?? this.recovery,
      );
}

typedef AgentUIStateWidgetBuilder = Widget Function(
  BuildContext context,
  AgentUIState state,
);

final class AgentUIBridgeBuilder extends StatelessWidget {
  const AgentUIBridgeBuilder({
    required this.bridge,
    required this.builder,
    super.key,
  });

  final AgentUIBridge bridge;
  final AgentUIStateWidgetBuilder builder;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: ValueListenableBuilder<AgentUIState>(
          valueListenable: bridge.state,
          builder: (context, value, _) => builder(context, value),
        ),
      );
}

final class AgentUIBridge {
  AgentUIBridge._(this._runtime)
      : state = ValueNotifier<AgentUIState>(
          AgentUIState(
            pairEpoch: _runtime.pairEpoch,
            progress: _runtime.progressSnapshot,
            matrix: _runtime.matrixState,
            recovery: null,
          ),
        ) {
    _progressSubscription =
        _runtime.progressSignals.listen(_onProgressSignal);
    _matrixSubscription =
        _runtime.matrixSignals.listen(_onMatrixSignal);
    _recoverySubscription =
        _runtime.recoverySignals.listen(_onRecoverySignal);
  }

  factory AgentUIBridge.attach(SystemAgentRuntime runtime) =>
      AgentUIBridge._(_SystemAgentRuntimePort(runtime));

  @visibleForTesting
  factory AgentUIBridge.attachPort(AgentUIRuntimePort runtime) =>
      AgentUIBridge._(runtime);

  final AgentUIRuntimePort _runtime;
  final ValueNotifier<AgentUIState> state;

  late final StreamSubscription<EpochUIValue<OfflineProgressSnapshot>>
      _progressSubscription;
  late final StreamSubscription<EpochUIValue<PolyglotMatrixState>>
      _matrixSubscription;
  late final StreamSubscription<EpochUIValue<RecoveryDirective>>
      _recoverySubscription;

  AgentUIState? _pendingState;
  int? _pendingEpoch;
  bool _flushScheduled = false;
  bool _closed = false;
  int _droppedStaleUpdates = 0;

  bool get isClosed => _closed;
  int get droppedStaleUpdates => _droppedStaleUpdates;
  int get pairEpoch => _runtime.pairEpoch;

  void switchPair({
    required String sourceLanguageTag,
    required String targetLanguageTag,
  }) {
    _ensureOpen();
    _discardPendingIfEpochChanged();
    _runtime.requestLearningPair(
      sourceLanguageTag: sourceLanguageTag,
      targetLanguageTag: targetLanguageTag,
    );
  }

  Future<T?> guardAsyncResult<T>(
    Future<T?> Function() operation,
  ) async {
    _ensureOpen();
    final submittedEpoch = _runtime.pairEpoch;
    final result = await operation();
    if (_closed || submittedEpoch != _runtime.pairEpoch) {
      _droppedStaleUpdates += 1;
      return null;
    }
    return result;
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _pendingState = null;
    _pendingEpoch = null;
    await _progressSubscription.cancel();
    await _matrixSubscription.cancel();
    await _recoverySubscription.cancel();
    state.dispose();
  }

  void _onProgressSignal(
    EpochUIValue<OfflineProgressSnapshot> signal,
  ) {
    _enqueue(
      signal.epoch,
      (current) => current.copyWith(progress: signal.value),
    );
  }

  void _onMatrixSignal(EpochUIValue<PolyglotMatrixState> signal) {
    _enqueue(
      signal.epoch,
      (current) => current.copyWith(matrix: signal.value),
    );
  }

  void _onRecoverySignal(EpochUIValue<RecoveryDirective> signal) {
    _enqueue(
      signal.epoch,
      (current) => current.copyWith(recovery: signal.value),
    );
  }

  void _enqueue(
    int epoch,
    AgentUIState Function(AgentUIState current) reduce,
  ) {
    if (_closed) return;
    if (epoch != _runtime.pairEpoch) {
      _droppedStaleUpdates += 1;
      return;
    }

    final base = _pendingEpoch == epoch && _pendingState != null
        ? _pendingState!
        : state.value.copyWith(pairEpoch: epoch);
    _pendingEpoch = epoch;
    _pendingState = reduce(base).copyWith(pairEpoch: epoch);

    if (_flushScheduled) return;
    _flushScheduled = true;
    scheduleMicrotask(_flushPending);
  }

  void _flushPending() {
    _flushScheduled = false;
    if (_closed) {
      _pendingState = null;
      _pendingEpoch = null;
      return;
    }

    final epoch = _pendingEpoch;
    final next = _pendingState;
    _pendingState = null;
    _pendingEpoch = null;
    if (epoch == null || next == null) return;

    if (epoch != _runtime.pairEpoch) {
      _droppedStaleUpdates += 1;
      return;
    }

    state.value = next.copyWith(pairEpoch: epoch);
  }

  void _discardPendingIfEpochChanged() {
    final epoch = _pendingEpoch;
    if (epoch == null || epoch == _runtime.pairEpoch) return;
    _pendingState = null;
    _pendingEpoch = null;
    _droppedStaleUpdates += 1;
  }

  void _ensureOpen() {
    if (_closed) {
      throw StateError('AgentUIBridge is closed.');
    }
  }
}

final class _SystemAgentRuntimePort implements AgentUIRuntimePort {
  const _SystemAgentRuntimePort(this.runtime);

  final SystemAgentRuntime runtime;

  @override
  int get pairEpoch => runtime.pairEpoch;

  @override
  OfflineProgressSnapshot get progressSnapshot =>
      runtime.progressSnapshot;

  @override
  PolyglotMatrixState? get matrixState => runtime.polyglotMatrixState;

  @override
  Stream<EpochUIValue<OfflineProgressSnapshot>> get progressSignals =>
      runtime.progressChanges.map(
        (value) => EpochUIValue<OfflineProgressSnapshot>(
          epoch: runtime.pairEpoch,
          value: value,
        ),
      );

  @override
  Stream<EpochUIValue<PolyglotMatrixState>> get matrixSignals =>
      runtime.polyglotMatrixChanges.map(
        (value) => EpochUIValue<PolyglotMatrixState>(
          epoch: runtime.pairEpoch,
          value: value,
        ),
      );

  @override
  Stream<EpochUIValue<RecoveryDirective>> get recoverySignals =>
      runtime.recoveryDirectives.map(
        (value) => EpochUIValue<RecoveryDirective>(
          epoch: runtime.pairEpoch,
          value: value,
        ),
      );

  @override
  void requestLearningPair({
    required String sourceLanguageTag,
    required String targetLanguageTag,
  }) {
    runtime.requestLearningPair(
      sourceLanguageTag: sourceLanguageTag,
      targetLanguageTag: targetLanguageTag,
    );
  }
}
