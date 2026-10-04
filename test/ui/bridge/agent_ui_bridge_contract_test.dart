import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/agents/polyglot_agent_models.dart';
import '../../../lib/core/agents/sys_error_recovery_fallback.dart';
import '../../../lib/core/storage/offline_progress_service.dart';
import '../../../lib/ui/bridge/agent_ui_bridge.dart';

void main() {
  test('fresh runtime signals coalesce into one UI notification', () async {
    final port = _FakeRuntimePort(epoch: 4);
    final bridge = AgentUIBridge.attachPort(port);
    var notifications = 0;
    bridge.state.addListener(() => notifications += 1);

    port.emitProgress(
      _snapshot(source: 'ar', target: 'de', points: 10),
      epoch: 4,
    );
    port.emitProgress(
      _snapshot(source: 'ar', target: 'de', points: 20),
      epoch: 4,
    );

    await _flushMicrotasks();

    expect(notifications, 1);
    expect(bridge.state.value.pairEpoch, 4);
    expect(bridge.state.value.progress.tasks['task-01']?.points, 20);

    await bridge.close();
    await port.close();
  });

  test('stale runtime signals never notify the UI', () async {
    final port = _FakeRuntimePort(epoch: 7);
    final bridge = AgentUIBridge.attachPort(port);
    var notifications = 0;
    bridge.state.addListener(() => notifications += 1);

    port.epoch = 8;
    port.emitProgress(
      _snapshot(source: 'ar', target: 'sv', points: 99),
      epoch: 7,
    );
    await _flushMicrotasks();

    expect(notifications, 0);
    expect(bridge.state.value.pairEpoch, 7);
    expect(bridge.droppedStaleUpdates, 1);

    port.emitProgress(
      _snapshot(source: 'ar', target: 'sv', points: 12),
      epoch: 8,
    );
    await _flushMicrotasks();

    expect(notifications, 1);
    expect(bridge.state.value.pairEpoch, 8);
    expect(bridge.state.value.progress.tasks['task-01']?.points, 12);

    await bridge.close();
    await port.close();
  });

  test('epoch changes before a scheduled flush suppress notifyListeners', () async {
    final port = _FakeRuntimePort(epoch: 10);
    final bridge = AgentUIBridge.attachPort(port);
    var notifications = 0;
    bridge.state.addListener(() => notifications += 1);

    port.emitProgress(
      _snapshot(source: 'de', target: 'sv', points: 8),
      epoch: 10,
    );
    port.epoch = 11;

    await _flushMicrotasks();

    expect(notifications, 0);
    expect(bridge.droppedStaleUpdates, 1);

    await bridge.close();
    await port.close();
  });

  test('epoch-bound async result is dropped after pair switch', () async {
    final port = _FakeRuntimePort(epoch: 2);
    final bridge = AgentUIBridge.attachPort(port);
    final completer = Completer<String?>();

    final pending = bridge.guardAsyncResult(() => completer.future);
    port.epoch = 3;
    completer.complete('stale-worker-result');

    expect(await pending, isNull);
    expect(bridge.droppedStaleUpdates, 1);

    await bridge.close();
    await port.close();
  });


  test('UI runtime dependency is isolated to AgentUIBridge', () {
    final uiRoot = Directory('lib/ui');
    final violations = <String>[];
    for (final entity in uiRoot.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final normalized = entity.path.replaceAll('\\', '/');
      final source = entity.readAsStringSync();
      if (source.contains('SystemAgentRuntime') &&
          normalized != 'lib/ui/bridge/agent_ui_bridge.dart') {
        violations.add(normalized);
      }
      final declaresWidget =
          source.contains('extends StatefulWidget') ||
          source.contains('extends StatelessWidget');
      if (declaresWidget &&
          (source.contains('AgentEventBus(') ||
              source.contains('AgentEndpoint') ||
              source.contains('.allEvents.listen('))) {
        violations.add('$normalized#event-bus-widget');
      }
    }

    expect(violations, isEmpty);

    final bridgeSource =
        File('lib/ui/bridge/agent_ui_bridge.dart').readAsStringSync();
    expect(bridgeSource, contains('ValueNotifier<AgentUIState>'));
    expect(bridgeSource, contains('scheduleMicrotask(_flushPending)'));
    expect(bridgeSource, contains('ValueListenableBuilder<AgentUIState>'));
    expect(bridgeSource, contains('RepaintBoundary('));
    expect(bridgeSource, isNot(contains('AgentEventBus(')));
  });
}

Future<void> _flushMicrotasks() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

OfflineProgressSnapshot _snapshot({
  required String source,
  required String target,
  required int points,
}) =>
    OfflineProgressSnapshot.decode(
      '{"schemaVersion":2,'
      '"sourceLanguageTag":"$source",'
      '"targetLanguageTag":"$target",'
      '"updatedAtEpochMs":1,'
      '"rows":[{"source_language_id":"$source",'
      '"target_language_id":"$target",'
      '"task_id":"task-01","points":$points,'
      '"bestScore":0.5,"completed":false,'
      '"mastery":"learning","updatedAtEpochMs":1}]}',
    );

final class _FakeRuntimePort implements AgentUIRuntimePort {
  _FakeRuntimePort({required int epoch})
      : _epoch = epoch,
        _progress = OfflineProgressSnapshot.empty();

  int _epoch;
  OfflineProgressSnapshot _progress;
  PolyglotMatrixState? _matrix;

  final _progressController =
      StreamController<EpochUIValue<OfflineProgressSnapshot>>.broadcast();
  final _matrixController =
      StreamController<EpochUIValue<PolyglotMatrixState>>.broadcast();
  final _recoveryController =
      StreamController<EpochUIValue<RecoveryDirective>>.broadcast();

  set epoch(int value) => _epoch = value;

  @override
  int get pairEpoch => _epoch;

  @override
  OfflineProgressSnapshot get progressSnapshot => _progress;

  @override
  PolyglotMatrixState? get matrixState => _matrix;

  @override
  Stream<EpochUIValue<OfflineProgressSnapshot>> get progressSignals =>
      _progressController.stream;

  @override
  Stream<EpochUIValue<PolyglotMatrixState>> get matrixSignals =>
      _matrixController.stream;

  @override
  Stream<EpochUIValue<RecoveryDirective>> get recoverySignals =>
      _recoveryController.stream;

  void emitProgress(OfflineProgressSnapshot value, {required int epoch}) {
    _progress = value;
    _progressController.add(EpochUIValue(epoch: epoch, value: value));
  }

  @override
  void requestLearningPair({
    required String sourceLanguageTag,
    required String targetLanguageTag,
  }) {}

  Future<void> close() async {
    await _progressController.close();
    await _matrixController.close();
    await _recoveryController.close();
  }
}
