import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_services/postal_logistics_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_services/services_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_services/services_screen.dart';
import 'package:deutsch_bilarabi/features/life_services/telecom_sub_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ServicesMasterOrchestrator _orchestrator() => ServicesMasterOrchestrator(
      entries: <ServicePhrase>[
        ...PostalLogisticsSubAgent.entries,
        ...TelecomSubAgent.entries,
      ],
    );

void main() {
  group('ServicesMasterOrchestrator', () {
    test('starts with both service categories and filters bilingual search',
        () {
      final orchestrator = _orchestrator();

      expect(
        orchestrator.selectedCategories,
        <ServiceCategory>{
          ServiceCategory.postal,
          ServiceCategory.telecom,
        },
      );
      expect(orchestrator.visibleEntries.length, 13);

      orchestrator.setQuery('Kundigung');

      expect(orchestrator.visibleEntries, isNotEmpty);
      expect(
        orchestrator.visibleEntries.every(
          (entry) => entry.category == ServiceCategory.telecom,
        ),
        isTrue,
      );
      expect(
        orchestrator.visibleEntries.any(
          (entry) => entry.id == 'telecom-contract-termination-inquiry',
        ),
        isTrue,
      );

      orchestrator.setQuery('استلام');
      expect(
        orchestrator.visibleEntries.any(
          (entry) => entry.id == 'postal-packstation-pickup',
        ),
        isTrue,
      );
    });

    test('category toggles isolate postal and telecom results', () {
      final orchestrator = _orchestrator();

      orchestrator.toggleCategory(ServiceCategory.telecom);

      expect(
        orchestrator.selectedCategories,
        <ServiceCategory>{ServiceCategory.postal},
      );
      expect(
        orchestrator.visibleEntries.every(
          (entry) => entry.category == ServiceCategory.postal,
        ),
        isTrue,
      );

      orchestrator.toggleCategory(ServiceCategory.postal);
      expect(orchestrator.visibleEntries, isEmpty);

      orchestrator.toggleCategory(ServiceCategory.telecom);
      expect(
        orchestrator.visibleEntries.every(
          (entry) => entry.category == ServiceCategory.telecom,
        ),
        isTrue,
      );
    });

    test('missing-package panic switches status and exposes quick steps', () {
      final orchestrator = _orchestrator();

      orchestrator.activateMissingPackagePanic();

      expect(
        orchestrator.trackingStatus,
        PackageTrackingStatus.missing,
      );
      expect(orchestrator.missingPackageExpanded, isTrue);
      expect(
        orchestrator.trackingGuidance.titleDe,
        'Sendung nicht angekommen',
      );
      expect(
        ServicesMasterOrchestrator.missingPackageSteps.length,
        3,
      );

      orchestrator.dismissMissingPackagePanic();
      expect(orchestrator.missingPackageExpanded, isFalse);
    });
  });

  group('service sub-agents', () {
    test('postal agent covers Einschreiben, customs and Packstation', () {
      final searchable = PostalLogisticsSubAgent.entries
          .expand(
            (entry) => <String>[
              entry.topicDe,
              entry.german,
              ...entry.tags,
            ],
          )
          .join(' ');

      expect(searchable, contains('Einschreiben'));
      expect(searchable, contains('Zollinhaltserklärung'));
      expect(searchable, contains('Packstation'));
    });

    test('telecom agent covers router, SIM and formal Kündigung inquiries', () {
      final searchable = TelecomSubAgent.entries
          .expand(
            (entry) => <String>[
              entry.topicDe,
              entry.german,
              ...entry.tags,
            ],
          )
          .join(' ');

      expect(searchable, contains('DSL'));
      expect(searchable, contains('Glasfaser'));
      expect(searchable, contains('Router'));
      expect(searchable, contains('SIM'));
      expect(searchable, contains('Kündigung'));
      expect(searchable, contains('schriftlich'));
    });
  });

  testWidgets(
      'services hub uses glass shell, scroll safety, bilingual search and panic bar',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ServicesMasterHubScreen(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Post, Pakete & Internet'), findsOneWidget);
    expect(find.text('الخدمات اليومية: البريد والإنترنت'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('missing-package-panic-bar')),
      findsOneWidget,
    );

    final search =
        find.byKey(const ValueKey<String>('services-search-field'));
    await tester.ensureVisible(search);
    await tester.enterText(search, 'Einschreiben');
    await tester.pump();

    expect(
      find.byKey(
        const ValueKey<String>('service-entry-postal-registered-letter'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('service-entry-telecom-dsl-setup'),
      ),
      findsNothing,
    );

    await tester.enterText(search, '');
    await tester.pump();

    final panic =
        find.byKey(const ValueKey<String>('missing-package-panic-bar'));
    await tester.ensureVisible(panic);
    await tester.tap(panic);
    await tester.pumpAndSettle();

    expect(find.text('Sendung nicht angekommen'), findsOneWidget);
    expect(
      find.textContaining('Nachforschung einleiten'),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
  });
}
