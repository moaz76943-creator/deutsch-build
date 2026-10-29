import 'dart:async';

import '../orchestration/orchestration.dart';
import 'polyglot_agent_models.dart';
import 'sys_polyglot_matrix_agent.dart';
import 'sys_tts_voice_agent.dart';
import 'sys_universal_grammar_agent.dart';

Future<void> main() async {
  final bus = AgentEventBus.isolated();
  final kernel = OrchestrationKernel(
    eventBus: bus,
    services: ServiceContainer(),
  );

  final localization = kernel.connect(
    AgentDescriptor(
      id: 'contract.localization',
      role: AgentRole.localization,
      subscriptions: const <String>{AgentTopics.contextUpdated},
    ),
  );
  final polyglotEndpoint = kernel.connect(
    AgentDescriptor(
      id: 'contract.polyglot',
      role: AgentRole.polyglot,
      subscriptions: const <String>{
        AgentTopics.localizationChanged,
      },
      observesTargetedEvents: true,
    ),
  );
  final grammarEndpoint = kernel.connect(
    AgentDescriptor(
      id: 'contract.grammar',
      role: AgentRole.grammar,
      subscriptions: const <String>{
        AgentTopics.polyglotMatrixChanged,
        AgentTopics.grammarRequest,
      },
    ),
  );
  final voiceEndpoint = kernel.connect(
    AgentDescriptor(
      id: 'contract.voice',
      role: AgentRole.voice,
      subscriptions: const <String>{
        AgentTopics.polyglotMatrixChanged,
        AgentTopics.ttsRequest,
      },
    ),
  );
  final systemEndpoint = kernel.connect(
    AgentDescriptor(
      id: 'contract.system',
      role: AgentRole.system,
      subscriptions: const <String>{
        AgentTopics.polyglotMatrixChanged,
        AgentTopics.grammarEngineChanged,
        AgentTopics.grammarResponse,
        AgentTopics.ttsPrepared,
      },
    ),
  );

  final polyglot = SysPolyglotMatrixAgent.start(endpoint: polyglotEndpoint);
  final grammar = SysUniversalGrammarAgent.start(endpoint: grammarEndpoint);
  final voice = SysTtsVoiceAgent.start(endpoint: voiceEndpoint);

  final matrixEvent = Completer<AgentEvent>();
  final engineEvent = Completer<AgentEvent>();
  final matrixSub = systemEndpoint
      .events(AgentTopics.polyglotMatrixChanged)
      .listen((event) {
    if (!matrixEvent.isCompleted) matrixEvent.complete(event);
  });
  final engineSub = systemEndpoint
      .events(AgentTopics.grammarEngineChanged)
      .listen((event) {
    if (!engineEvent.isCompleted) engineEvent.complete(event);
  });

  localization.publish(
    topic: AgentTopics.localizationChanged,
    targetRoles: const <AgentRole>{
      AgentRole.design,
      AgentRole.routing,
    },
    context: AgentContextSnapshot.empty('polyglot-contract-1'),
    payload: const <String, Object?>{
      'revision': 7,
      'userLocale': 'ar-JO',
      'sourceLocale': 'ar',
      'targetLocale': 'de-DE',
      'direction': 'rtl',
      'isRtl': true,
      'loadedLocales': <String>['ar-JO', 'de-DE'],
    },
  );

  final changed = await matrixEvent.future.timeout(
    const Duration(seconds: 1),
  );
  final state = PolyglotMatrixState.fromEvent(changed);
  _expect(state.sourceLanguageTag, 'ar', 'matrix source language');
  _expect(state.targetLanguageTag, 'de-DE', 'matrix target language');
  _expect(state.directedPairKey, 'ar->de-DE', 'directed pair identity');
  _expect(state.revision, 7, 'localization revision carried into matrix');

  final engineChanged = await engineEvent.future.timeout(
    const Duration(seconds: 1),
  );
  _expect(
    engineChanged.payload['engineId'],
    'german.core.v1',
    'German target loads German grammar facade',
  );
  _expect(
    engineChanged.payload['targetLanguage'],
    'de-DE',
    'grammar selection follows matrix target',
  );

  final grammarResponse = Completer<AgentEvent>();
  final grammarSub = systemEndpoint
      .events(AgentTopics.grammarResponse)
      .listen((event) {
    if (!grammarResponse.isCompleted &&
        event.context.correlationId == 'grammar-contract-1') {
      grammarResponse.complete(event);
    }
  });

  systemEndpoint.publish(
    topic: AgentTopics.grammarRequest,
    targetRoles: const <AgentRole>{AgentRole.grammar},
    context: AgentContextSnapshot.empty('grammar-contract-1'),
    payload: const <String, Object?>{
      'capability': 'konjunktiv_ii',
      'seed': 11,
      'count': 2,
    },
  );

  final grammarEvent = await grammarResponse.future.timeout(
    const Duration(seconds: 1),
  );
  final grammarResult = GrammarAgentResult.fromEvent(grammarEvent);
  _expect(grammarResult.ok, true, 'German grammar request succeeds');
  _expect(grammarResult.engineId, 'german.core.v1', 'German engine id');
  _expect(grammarResult.items.length, 2, 'grammar result item count');

  final voiceResponse = Completer<AgentEvent>();
  final voiceSub = systemEndpoint
      .events(AgentTopics.ttsPrepared)
      .listen((event) {
    if (!voiceResponse.isCompleted &&
        event.context.correlationId == 'tts-contract-1') {
      voiceResponse.complete(event);
    }
  });

  systemEndpoint.publish(
    topic: AgentTopics.ttsRequest,
    targetRoles: const <AgentRole>{AgentRole.voice},
    context: AgentContextSnapshot.empty('tts-contract-1'),
    payload: const <String, Object?>{
      'text': 'Guten Morgen',
      'targetLanguage': 'de-DE',
      'speed': 0.85,
    },
  );

  final voiceEvent = await voiceResponse.future.timeout(
    const Duration(seconds: 1),
  );
  final dispatch = TtsVoiceDispatch.fromEvent(voiceEvent);
  _expect(dispatch.accepted, true, 'TTS request is prepared');
  _expect(dispatch.text, 'Guten Morgen', 'TTS text is preserved');
  _expect(dispatch.targetLanguageTag, 'de-DE', 'TTS target language');
  _expect(dispatch.speed, 0.85, 'TTS speed is preserved');
  _expect(
    dispatch.backend,
    'flutter_tts.offline.v1',
    'production Flutter TTS backend is bound',
  );

  await voiceSub.cancel();
  await grammarSub.cancel();
  await engineSub.cancel();
  await matrixSub.cancel();
  await voice.close();
  await grammar.close();
  await polyglot.close();
  await kernel.close();

  _expect(bus.isClosed, true, 'isolated bus closes cleanly');
}

void _expect(Object? actual, Object? expected, String contract) {
  if (actual != expected) {
    throw StateError(
      'Contract failed: $contract. Expected <$expected>, got <$actual>.',
    );
  }
}
