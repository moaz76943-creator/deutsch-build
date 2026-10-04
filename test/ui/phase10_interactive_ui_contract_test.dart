import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/core/agents/memory_models.dart';
import '../../lib/core/design/flashcards_3d/flashcard_3d_models.dart';
import '../../lib/core/orchestration/orchestration.dart';
import '../../lib/core/storage/offline_progress_service.dart';
import '../../lib/ui/phase3/flip_card_widget.dart';
import '../../lib/ui/phase3/phase10_presentation_bridge.dart';
import '../../lib/ui/phase3/phase10_tasks_track.dart';

void main() {
  testWidgets('FlipCardWidget flips with tap and disposes its ticker', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlipCardWidget(
            semanticLabel: 'test-card',
            front: Text('Vorderseite'),
            back: Text('Rückseite'),
          ),
        ),
      ),
    );

    expect(find.text('Vorderseite'), findsOneWidget);
    expect(find.text('Rückseite'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('phase10-flip-card')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 360));

    expect(find.text('Rückseite'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('FlipCardWidget supports RTL without changing flip semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: FlipCardWidget(
              semanticLabel: 'rtl-card',
              front: Text('أمام'),
              back: Text('خلف'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('phase10-flip-card')));
    await tester.pumpAndSettle();
    expect(find.text('خلف'), findsOneWidget);
  });

  testWidgets('Tasks track reacts to OfflineProgressSnapshot stream', (
    tester,
  ) async {
    final controller = StreamController<OfflineProgressSnapshot>.broadcast();
    final initial = OfflineProgressSnapshot.decode(
      '{"schemaVersion":1,"sourceLanguageTag":"ar",'
      '"targetLanguageTag":"de","updatedAtEpochMs":1,"tasks":[]}',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Phase10TasksTrackView(
            initialSnapshot: initial,
            progressStream: controller.stream,
          ),
        ),
      ),
    );

    expect(find.textContaining('ar → de'), findsOneWidget);
    expect(find.byKey(const ValueKey('phase10-task-task-01')), findsOneWidget);

    controller.add(
      OfflineProgressSnapshot.decode(
        '{"schemaVersion":1,"sourceLanguageTag":"ar",'
        '"targetLanguageTag":"de","updatedAtEpochMs":2,"tasks":['
        '{"taskId":"task-01","points":40,"bestScore":0.92,'
        '"completed":true,"mastery":"mastered","updatedAtEpochMs":2}]}',
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('phase10-mastery-task-01')), findsOneWidget);
    expect(find.text('40 pts'), findsOneWidget);

    await controller.close();
  });

  test('Presentation bridge mirrors progress events and closes cleanly', () async {
    final bus = AgentEventBus.isolated();
    final bridge = await Phase10PresentationBridge.isolated(
      eventBus: bus,
      validationStore: _MemoryStore(),
      initialSnapshot: OfflineProgressSnapshot.empty(),
    );
    final kernel = OrchestrationKernel(
      eventBus: bus,
      services: ServiceContainer(),
    );
    final publisher = kernel.connect(
      AgentDescriptor(
        id: 'phase10.contract.publisher',
        role: AgentRole.task,
        subscriptions: const <String>{AgentTopics.contextUpdated},
      ),
    );

    final next = bridge.progressStream.firstWhere(
      (snapshot) => snapshot.tasks['task-46']?.points == 3,
    );

    publisher.publish(
      topic: AgentTopics.learningProgress,
      targetRoles: const <AgentRole>{AgentRole.memory},
      context: AgentContextSnapshot.empty('phase10.progress'),
      payload: const <String, Object?>{
        'taskId': 'task-46',
        'score': 1.0,
        'completed': false,
        'points': 3,
        'occurredAtEpochMs': 4,
      },
    );

    final snapshot = await next.timeout(const Duration(seconds: 1));
    expect(snapshot.tasks['task-46']?.points, 3);

    final card = const Flashcard3DData(
      id: 'phase10-card',
      frontText: 'Fahrkarte',
      backText: 'تذكرة',
      frontLanguageCode: 'de',
      backLanguageCode: 'ar',
    );
    final firstValidation = await bridge.validateCard(card);
    final secondValidation = await bridge.validateCard(card);
    expect(firstValidation.validated, isTrue);
    expect(firstValidation.cacheHit, isFalse);
    expect(secondValidation.cacheHit, isTrue);

    bridge.recordCardInteraction(
      cardId: card.id,
      score: 1,
      points: 3,
    );
    await bridge.flush();
    expect(bridge.batchStats.processed, greaterThanOrEqualTo(1));
    expect(bridge.validationCacheHits, greaterThanOrEqualTo(1));

    await bridge.close();
    expect(bridge.isClosed, isTrue);

    await kernel.close();
    await bus.close();
  });
}

final class _MemoryStore implements MemoryAgentStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String encoded) async {
    value = encoded;
  }
}
