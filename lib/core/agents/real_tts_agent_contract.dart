import 'dart:async';

import '../orchestration/orchestration.dart';
import 'polyglot_agent_models.dart';
import 'sys_tts_voice_agent.dart';

Future<void> main() async {
  final bus = AgentEventBus.isolated();
  final kernel = OrchestrationKernel(
    eventBus: bus,
    services: ServiceContainer(),
  );

  final voiceEndpoint = kernel.connect(
    AgentDescriptor(
      id: 'phase8.contract.voice',
      role: AgentRole.voice,
      subscriptions: const <String>{
        AgentTopics.polyglotMatrixChanged,
        AgentTopics.ttsRequest,
      },
    ),
  );
  final systemEndpoint = kernel.connect(
    AgentDescriptor(
      id: 'phase8.contract.system',
      role: AgentRole.system,
      subscriptions: const <String>{
        AgentTopics.ttsPrepared,
        AgentTopics.ttsCompleted,
        AgentTopics.ttsFailed,
      },
    ),
  );
  final producer = kernel.connect(
    AgentDescriptor(
      id: 'phase8.contract.producer',
      role: AgentRole.task,
      subscriptions: const <String>{AgentTopics.contextUpdated},
    ),
  );

  final backend = _ContractBackend();
  final voice = SysTtsVoiceAgent.start(
    endpoint: voiceEndpoint,
    backend: backend,
  );

  producer.publish(
    topic: AgentTopics.polyglotMatrixChanged,
    targetRoles: const <AgentRole>{
      AgentRole.grammar,
      AgentRole.voice,
      AgentRole.system,
    },
    context: AgentContextSnapshot.empty('phase8-matrix'),
    payload: const <String, Object?>{
      'revision': 1,
      'userLanguage': 'ar',
      'sourceLanguage': 'ar',
      'targetLanguage': 'de-DE',
      'directedPair': 'ar->de-DE',
    },
  );
  await Future<void>.delayed(Duration.zero);

  final prepared = _next(
    systemEndpoint,
    AgentTopics.ttsPrepared,
    'phase8-tts-ok',
  );
  final completed = _next(
    systemEndpoint,
    AgentTopics.ttsCompleted,
    'phase8-tts-ok',
  );

  producer.publish(
    topic: AgentTopics.ttsRequest,
    targetRoles: const <AgentRole>{AgentRole.voice},
    context: AgentContextSnapshot.empty('phase8-tts-ok'),
    payload: const <String, Object?>{
      'text': 'Guten Morgen',
      'targetLanguage': 'de-DE',
      'speed': 0.85,
    },
  );

  final preparedEvent = await prepared;
  final dispatch = TtsVoiceDispatch.fromEvent(preparedEvent);
  _expect(dispatch.accepted, true, 'request is accepted');
  _expect(dispatch.backend, 'contract.tts', 'backend id is exposed');

  final completedEvent = await completed;
  _expect(
    completedEvent.payload['backend'],
    'contract.tts',
    'completion identifies backend',
  );
  _expect(
    completedEvent.payload['targetLanguage'],
    'de-DE',
    'completion preserves target locale',
  );
  _expect(
    backend.lastRequest?.text,
    'Guten Morgen',
    'backend receives exact text',
  );
  _expect(
    backend.lastRequest?.targetLanguageTag,
    'de-DE',
    'backend receives exact target language',
  );
  _expect(backend.lastRequest?.speed, 0.85, 'backend receives speed');

  backend.nextFailure = 'unsupported_language';
  final failed = _next(
    systemEndpoint,
    AgentTopics.ttsFailed,
    'phase8-tts-fail',
  );
  producer.publish(
    topic: AgentTopics.ttsRequest,
    targetRoles: const <AgentRole>{AgentRole.voice},
    context: AgentContextSnapshot.empty('phase8-tts-fail'),
    payload: const <String, Object?>{
      'text': 'Noch einmal',
      'targetLanguage': 'de-DE',
      'speed': 1.0,
    },
  );

  final failedEvent = await failed;
  _expect(
    failedEvent.payload['reason'],
    'unsupported_language',
    'unsupported language fails cleanly',
  );

  await voice.close();
  _expect(backend.stopCount > 0, true, 'close stops playback');
  _expect(backend.disposed, true, 'close disposes backend');

  await kernel.close();
}

Future<AgentEvent> _next(
  AgentEndpoint endpoint,
  String topic,
  String correlationId,
) =>
    endpoint
        .events(topic)
        .firstWhere(
          (event) => event.context.correlationId == correlationId,
        )
        .timeout(const Duration(seconds: 1));

final class _ContractBackend implements TtsVoiceBackendPort {
  @override
  String get backendId => 'contract.tts';

  TtsVoiceRequest? lastRequest;
  String? nextFailure;
  int stopCount = 0;
  bool disposed = false;

  @override
  Future<TtsBackendResult> speak(TtsVoiceRequest request) async {
    lastRequest = request;
    final failure = nextFailure;
    nextFailure = null;
    return failure == null
        ? const TtsBackendResult.completed()
        : TtsBackendResult.failed(failure);
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void _expect(Object? actual, Object? expected, String contract) {
  if (actual != expected) {
    throw StateError(
      'Contract failed: $contract. Expected <$expected>, got <$actual>.',
    );
  }
}
