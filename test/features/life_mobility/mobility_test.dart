import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_mobility/application/mobility_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_mobility/data/local_mobility_repository.dart';
import 'package:deutsch_bilarabi/features/life_mobility/domain/mobility_models.dart';
import 'package:deutsch_bilarabi/features/life_mobility/presentation/mobility_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = LocalMobilityRepository();

  test('repository covers every requested mobility topic', () {
    final topics = repository.all().map((item) => item.topic).toSet();

    expect(topics, containsAll(MobilityTopic.values));
    expect(repository.all().map((item) => item.level).toSet(),
        containsAll(MobilityLevel.values));
  });

  test('long-distance sub-agent covers DB disruption and reservation flows', () {
    final agent = LongDistanceTrainSubAgent(repository);

    expect(agent.platformChanges(), isNotEmpty);
    expect(agent.delays(), isNotEmpty);
    expect(agent.seatReservations(), isNotEmpty);
    expect(
      agent.platformChanges().any((item) => item.phraseDe.contains('Gleis')),
      isTrue,
    );
  });

  test('local transit sub-agent covers tickets and bus connections', () {
    final agent = LocalTransitSubAgent(repository);

    expect(agent.localTickets(), isNotEmpty);
    expect(agent.deutschlandticket(), isNotEmpty);
    expect(agent.busConnections(), isNotEmpty);
    expect(
      agent.deutschlandticket()
          .any((item) => item.phraseDe.contains('Deutschlandticket')),
      isTrue,
    );
  });

  test('master orchestrator filters by level and performs fast search', () {
    final orchestrator = MobilityMasterOrchestrator(repository);

    orchestrator.setLevel(MobilityLevel.b1);
    expect(orchestrator.visibleItems, isNotEmpty);
    expect(
      orchestrator.visibleItems.every((item) => item.level == MobilityLevel.b1),
      isTrue,
    );

    orchestrator.search('Gleis');
    expect(orchestrator.visibleItems, isNotEmpty);
    expect(
      orchestrator.visibleItems.every(
        (item) => item.searchableText.toLowerCase().contains('gleis'),
      ),
      isTrue,
    );

    orchestrator.clearSearch();
    expect(orchestrator.query, isEmpty);
  });

  test('platform panic bar exposes an actionable Gleiswechsel guide', () {
    final orchestrator = MobilityMasterOrchestrator(repository);

    expect(orchestrator.isPanicBarOpen, isFalse);
    orchestrator.togglePanicBar();

    expect(orchestrator.isPanicBarOpen, isTrue);
    expect(orchestrator.platformPanicSteps.length, greaterThanOrEqualTo(3));
    expect(
      orchestrator.platformPanicSteps
          .any((step) => step.titleDe.contains('Anzeigetafel')),
      isTrue,
    );
  });

  test('search is case-insensitive and searches Arabic guidance too', () {
    expect(repository.search('DEUTSCHLANDTICKET'), isNotEmpty);
    expect(repository.search('الحافلة'), isNotEmpty);
    expect(repository.search('   '), repository.all());
  });

  testWidgets('hub uses glass cards, scrolling and explicit BiDi', (tester) async {
    final orchestrator = MobilityMasterOrchestrator(repository);

    await tester.pumpWidget(
      MaterialApp(home: MobilityScreen(orchestrator: orchestrator)),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.byType(Directionality), findsWidgets);
    expect(find.textContaining('Mobilität'), findsWidgets);
    expect(find.textContaining('Gleiswechsel'), findsWidgets);
    expect(find.textContaining('Deutschlandticket'), findsWidgets);
  });
}
