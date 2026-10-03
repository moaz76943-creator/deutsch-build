import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_driving/application/driving_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_driving/application/fahrschule_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_driving/application/vehicle_admin_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_driving/domain/driving_models.dart';
import 'package:deutsch_bilarabi/features/life_driving/presentation/driving_master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DrivingMasterOrchestrator', () {
    test('starts in Fahrschule and exposes only driving-school content', () {
      final orchestrator = DrivingMasterOrchestrator();
      addTearDown(orchestrator.dispose);

      expect(orchestrator.category, DrivingCategory.fahrschule);
      expect(orchestrator.visibleItems, isNotEmpty);
      expect(
        orchestrator.visibleItems.every(
          (item) => item.category == DrivingCategory.fahrschule,
        ),
        isTrue,
      );
    });

    test('Fahrschule sub-agent covers enrollment, theory, practical and first aid', () {
      const agent = FahrschuleSubAgent();
      final topics = agent.items.map((item) => item.topic);

      expect(
        topics,
        containsAll(<DrivingTopic>[
          DrivingTopic.enrollment,
          DrivingTopic.theoryClass,
          DrivingTopic.practicalLesson,
          DrivingTopic.firstAid,
        ]),
      );

      final joined = agent.items
          .map((item) => '${item.titleDe} ${item.german} ${item.tags.join(' ')}')
          .join(' ');

      expect(joined, contains('Theorieunterricht'));
      expect(joined, contains('Schulterblick'));
      expect(joined, contains('Erste-Hilfe-Kurs'));
    });

    test('vehicle admin sub-agent uses strict registration and TÜV terminology', () {
      const agent = VehicleAdminSubAgent();
      final joined = agent.items
          .map((item) => '${item.titleDe} ${item.german} ${item.tags.join(' ')}')
          .join(' ');

      expect(joined, contains('Kfz-Zulassungsstelle'));
      expect(joined, contains('Hauptuntersuchung'));
      expect(joined, contains('TÜV'));
      expect(joined, contains('Umweltplakette'));
    });

    test('switching category clears search and prevents cross-agent leakage', () {
      final orchestrator = DrivingMasterOrchestrator();
      addTearDown(orchestrator.dispose);

      orchestrator.setSearchQuery('Erste-Hilfe');
      expect(orchestrator.visibleItems, isNotEmpty);

      orchestrator.switchCategory(DrivingCategory.vehicleAdmin);

      expect(orchestrator.searchQuery, isEmpty);
      expect(
        orchestrator.visibleItems.every(
          (item) => item.category == DrivingCategory.vehicleAdmin,
        ),
        isTrue,
      );
      expect(
        orchestrator.visibleItems.any(
          (item) => item.topic == DrivingTopic.firstAid,
        ),
        isFalse,
      );
    });

    test('search matches German and Arabic driving vocabulary', () {
      final orchestrator = DrivingMasterOrchestrator();
      addTearDown(orchestrator.dispose);

      orchestrator.setSearchQuery('إسعافات');
      expect(
        orchestrator.visibleItems.any(
          (item) => item.topic == DrivingTopic.firstAid,
        ),
        isTrue,
      );

      orchestrator.switchCategory(DrivingCategory.vehicleAdmin);
      orchestrator.setSearchQuery('Umweltplakette');
      expect(orchestrator.visibleItems, hasLength(1));
      expect(
        orchestrator.visibleItems.single.topic,
        DrivingTopic.emissionsSticker,
      );
    });

    test('quick exam prep bar includes theory, practical and first-aid cues', () {
      final orchestrator = DrivingMasterOrchestrator();
      addTearDown(orchestrator.dispose);

      final joined = orchestrator.quickExamPrep
          .map((item) => '${item.focusDe} ${item.german}')
          .join(' ');

      expect(joined, contains('Theorieprüfung'));
      expect(joined, contains('Praktische Prüfung'));
      expect(joined, contains('Erste-Hilfe'));
    });
  });

  testWidgets('screen uses glass cards, safe scrolling and explicit BiDi', (
    tester,
  ) async {
    final orchestrator = DrivingMasterOrchestrator();
    addTearDown(orchestrator.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: DrivingMasterScreen(orchestrator: orchestrator),
      ),
    );

    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('driving-search')),
      findsOneWidget,
    );

    final german = tester.widget<Directionality>(
      find.byKey(const ValueKey<String>('driving-german-direction')),
    );
    final arabic = tester.widget<Directionality>(
      find.byKey(const ValueKey<String>('driving-arabic-direction')),
    );

    expect(german.textDirection, TextDirection.ltr);
    expect(arabic.textDirection, TextDirection.rtl);
    expect(find.text('Fahrschule'), findsWidgets);
    expect(find.text('Zulassung & TÜV'), findsWidgets);
  });
}
