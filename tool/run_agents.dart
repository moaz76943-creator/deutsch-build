import 'dart:convert';
import 'dart:io';

import '../lib/core/orchestration/agent_batch_processing.dart';
import '../lib/core/orchestration/agent_data_integrity.dart';
import '../lib/core/orchestration/event_bus.dart';
import '../lib/core/orchestration/orchestration_kernel.dart';
import '../lib/core/orchestration/orchestration_models.dart';
import '../lib/core/orchestration/service_container.dart';

Future<void> main() async {
  final stopwatch = Stopwatch()..start();

  final batch = await _verifyBatchPipeline();
  final integrity = _verifyDataIntegrity();
  final eventBus = await _verifyEventBusPulse();
  final sources = _verifyAgentSources();

  stopwatch.stop();
  stdout.writeln(
    jsonEncode(<String, Object?>{
      'ok': true,
      'elapsedMs': stopwatch.elapsedMilliseconds,
      'batch': batch,
      'integrity': integrity,
      'eventBus': eventBus,
      'sources': sources,
    }),
  );
}

Future<Map<String, Object?>> _verifyBatchPipeline() async {
  final batches = <List<String>>[];
  final queue = AgentBatchQueue<_PulseRequest>(
    maxBatchSize: 3,
    maxPending: 16,
    flushDelay: const Duration(milliseconds: 1),
    dedupeKeyOf: (request) => request.id,
    processBatch: (items) async {
      batches.add(
        items.map((item) => item.id).toList(growable: false),
      );
      await Future<void>.delayed(Duration.zero);
    },
  );

  final first = queue.submit(
    const _PulseRequest('grammar:ar-de:cases'),
  );
  final duplicate = queue.submit(
    const _PulseRequest('grammar:ar-de:cases'),
  );
  final futures = <Future<void>>[
    first,
    duplicate,
    queue.submit(const _PulseRequest('vocab:ar-de:travel')),
    queue.submit(const _PulseRequest('grammar:ar-fr:agreement')),
    queue.submit(const _PulseRequest('vocab:ar-fr:travel')),
    queue.submit(const _PulseRequest('grammar:ar-es:agreement')),
  ];

  await queue.flush();
  await Future.wait(futures);
  await queue.close();

  final flattened = batches.expand((batch) => batch).toList(growable: false);
  _expect(flattened.length, 5, 'batch queue deduplicates pending work');
  _expect(queue.stats.submitted, 5, 'unique submissions are counted');
  _expect(queue.stats.coalesced, 1, 'duplicate submissions are coalesced');
  _expect(
    batches.every((batch) => batch.length <= 3),
    true,
    'batch size is bounded',
  );

  return <String, Object?>{
    'batches': queue.stats.batches,
    'processed': queue.stats.processed,
    'coalesced': queue.stats.coalesced,
    'maxPendingObserved': queue.stats.maxPendingObserved,
  };
}

Map<String, Object?> _verifyDataIntegrity() {
  const verifier = AgentDataIntegrityVerifier();

  const clean = <AgentDataRecord>[
    AgentDataRecord(
      recordId: 'vocab.travel.ticket.de',
      domain: AgentDataDomain.vocabulary,
      sourceLanguage: 'ar',
      targetLanguage: 'de',
      canonicalKey: 'travel.ticket',
      fingerprint: 'fahrkarte',
    ),
    AgentDataRecord(
      recordId: 'vocab.travel.ticket.fr',
      domain: AgentDataDomain.vocabulary,
      sourceLanguage: 'ar',
      targetLanguage: 'fr',
      canonicalKey: 'travel.ticket',
      fingerprint: 'billet',
    ),
    AgentDataRecord(
      recordId: 'grammar.case.accusative.de',
      domain: AgentDataDomain.grammar,
      sourceLanguage: 'ar',
      targetLanguage: 'de',
      canonicalKey: 'case.accusative',
      fingerprint: 'de-akkusativ-v1',
    ),
  ];

  final cleanReport = verifier.verify(clean);
  _expect(cleanReport.isValid, true, 'clean multilingual data is accepted');

  final duplicateReport = verifier.verify(
    const <AgentDataRecord>[
      ...clean,
      AgentDataRecord(
        recordId: 'vocab.travel.ticket.de.copy',
        domain: AgentDataDomain.vocabulary,
        sourceLanguage: 'ar',
        targetLanguage: 'de',
        canonicalKey: 'travel.ticket',
        fingerprint: 'fahrkarte',
      ),
    ],
  );
  _expect(
    duplicateReport.hasCode(AgentDataIntegrityCode.duplicateEntry),
    true,
    'same directed-pair entry is rejected as duplicate',
  );

  final conflictReport = verifier.verify(
    const <AgentDataRecord>[
      ...clean,
      AgentDataRecord(
        recordId: 'grammar.case.accusative.de',
        domain: AgentDataDomain.grammar,
        sourceLanguage: 'ar',
        targetLanguage: 'fr',
        canonicalKey: 'case.accusative',
        fingerprint: 'fr-accusatif-v1',
      ),
    ],
  );
  _expect(
    conflictReport.hasCode(AgentDataIntegrityCode.crossPairIdCollision),
    true,
    'record ids cannot silently cross language pairs',
  );

  var guardedBatchRejected = false;
  try {
    verifyGuardedAgentBatch(
      <AgentBatchEvent>[
        AgentBatchEvent(
          dedupeKey: 'guard-a',
          topic: AgentTopics.grammarRequest,
          context: AgentContextSnapshot.empty('guard-a'),
          targetRoles: const <AgentRole>{AgentRole.grammar},
          payload: const <String, Object?>{},
          integrityRecord: const AgentDataRecord(
            recordId: 'guard.rule.a',
            domain: AgentDataDomain.grammar,
            sourceLanguage: 'ar',
            targetLanguage: 'de',
            canonicalKey: 'case.accusative',
            fingerprint: 'de-akk-v1',
          ),
        ),
        AgentBatchEvent(
          dedupeKey: 'guard-b',
          topic: AgentTopics.grammarRequest,
          context: AgentContextSnapshot.empty('guard-b'),
          targetRoles: const <AgentRole>{AgentRole.grammar},
          payload: const <String, Object?>{},
          integrityRecord: const AgentDataRecord(
            recordId: 'guard.rule.b',
            domain: AgentDataDomain.grammar,
            sourceLanguage: 'ar',
            targetLanguage: 'de',
            canonicalKey: 'case.accusative',
            fingerprint: 'de-akk-v1',
          ),
        ),
      ],
    );
  } on AgentBatchIntegrityException {
    guardedBatchRejected = true;
  }
  _expect(
    guardedBatchRejected,
    true,
    'guarded grammar batch rejects duplicate data',
  );

  return <String, Object?>{
    'checked': cleanReport.checkedRecords,
    'duplicateGuard': true,
    'crossPairGuard': true,
    'eventBatchGuard': true,
  };
}

Future<Map<String, Object?>> _verifyEventBusPulse() async {
  final bus = AgentEventBus.isolated();
  final kernel = OrchestrationKernel(
    eventBus: bus,
    services: ServiceContainer(),
  );
  final producer = kernel.connect(
    AgentDescriptor(
      id: 'pulse.producer',
      role: AgentRole.task,
      subscriptions: const <String>{AgentTopics.contextUpdated},
    ),
  );
  final grammar = kernel.connect(
    AgentDescriptor(
      id: 'pulse.grammar',
      role: AgentRole.grammar,
      subscriptions: const <String>{AgentTopics.grammarRequest},
    ),
  );

  final received = <String>[];
  final subscription = grammar
      .events(AgentTopics.grammarRequest)
      .listen((event) {
    received.add(event.context.correlationId);
  });

  final dispatcher = producer.createBatchDispatcher(
    maxBatchSize: 4,
    maxPending: 32,
    flushDelay: Duration.zero,
  );

  final submissions = <Future<void>>[];
  for (var index = 0; index < 8; index++) {
    submissions.add(
      dispatcher.submit(
        AgentBatchEvent(
          dedupeKey: 'grammar:ar-de:$index',
          topic: AgentTopics.grammarRequest,
          context: AgentContextSnapshot.empty('pulse-$index'),
          targetRoles: const <AgentRole>{AgentRole.grammar},
          payload: <String, Object?>{
            'targetLanguage': 'de',
            'capability': 'pulse-$index',
          },
          integrityRecord: AgentDataRecord(
            recordId: 'pulse.grammar.$index',
            domain: AgentDataDomain.grammar,
            sourceLanguage: 'ar',
            targetLanguage: 'de',
            canonicalKey: 'pulse.rule.$index',
            fingerprint: 'pulse-rule-$index-v1',
          ),
        ),
      ),
    );
  }

  await dispatcher.flush();
  await Future.wait(submissions);
  await Future<void>.delayed(Duration.zero);

  _expect(received.length, 8, 'batched events reach the Event Bus');
  _expect(
    received.toSet().length,
    8,
    'batched events keep correlation ids unique',
  );

  await dispatcher.close();
  await subscription.cancel();
  await kernel.close();

  return <String, Object?>{
    'published': received.length,
    'isolatedBusClosed': bus.isClosed,
  };
}

Map<String, Object?> _verifyAgentSources() {
  final root = Directory('lib/core/agents');
  if (!root.existsSync()) {
    throw StateError('lib/core/agents is missing.');
  }

  var files = 0;
  var bytes = 0;
  final incomplete = RegExp(r'\b(?:UnimplementedError|NotImplementedException)\b');
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    files += 1;
    final source = entity.readAsStringSync();
    bytes += source.length;
    if (incomplete.hasMatch(source)) {
      throw StateError('Incomplete implementation found in ${entity.path}.');
    }
  }

  _expect(files > 0, true, 'agent source tree is non-empty');
  return <String, Object?>{
    'dartFiles': files,
    'sourceBytes': bytes,
  };
}

final class _PulseRequest {
  const _PulseRequest(this.id);

  final String id;
}

void _expect(Object? actual, Object? expected, String contract) {
  if (actual != expected) {
    throw StateError(
      'Pulse contract failed: $contract. '
      'Expected <$expected>, got <$actual>.',
    );
  }
}
