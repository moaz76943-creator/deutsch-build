import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('main routes recovery UI through AgentUIBridge only', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, contains("import 'ui/bridge/agent_ui_bridge.dart';"));
    expect(source, contains('AgentUIBridge.attach(systemAgents)'));
    expect(source, contains('AgentUIBridgeBuilder('));
    expect(source, isNot(contains('recoveryDirectives.listen(')));
    expect(source, isNot(contains('StreamSubscription<RecoveryDirective>')));
  });

  test('main closes bridge before runtime and keeps UI runtime-neutral', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, contains('await bridge.close()'));
    expect(source, contains('await runtime.close()'));

    final appSection = source.substring(
      source.indexOf('final class _ActivatedPhase3App'),
      source.indexOf('final class _RecoverySafeHome'),
    );
    expect(appSection, isNot(contains('SystemAgentRuntime')));
    expect(appSection, contains('AgentUIBridge'));
  });
}
