import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_jobcenter_employment/application/jobcenter_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_jobcenter_employment/application/jobcenter_module_dependencies.dart';
import 'package:deutsch_bilarabi/features/life_jobcenter_employment/domain/jobcenter_models.dart';
import 'package:deutsch_bilarabi/features/life_jobcenter_employment/presentation/life_jobcenter_employment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JobcenterModuleDependencies', () {
    test('provides isolated routes for consultation and applications', () {
      final dependencies = JobcenterModuleDependencies.standard();

      expect(dependencies.consultationRoute.id, 'jobcenter-consultation');
      expect(
        dependencies.consultationRoute.path,
        '/life/jobcenter/consultation',
      );
      expect(dependencies.applicationsRoute.id, 'jobcenter-applications');
      expect(
        dependencies.applicationsRoute.path,
        '/life/jobcenter/applications',
      );
    });

    test('supports route dependency injection without global router coupling', () {
      const dependencies = JobcenterModuleDependencies(
        consultationRoute: JobcenterRouteSpec(
          id: 'custom-consultation',
          path: '/custom/consultation',
          labelDe: 'Beratung',
          labelAr: 'استشارة',
        ),
        applicationsRoute: JobcenterRouteSpec(
          id: 'custom-applications',
          path: '/custom/applications',
          labelDe: 'Anträge',
          labelAr: 'طلبات',
        ),
      );
      final orchestrator = JobcenterMasterOrchestrator(
        dependencies: dependencies,
      );

      orchestrator.setSection(JobcenterSection.consultationJobs);
      expect(orchestrator.activeRoute?.path, '/custom/consultation');

      orchestrator.setSection(JobcenterSection.applicationsNotices);
      expect(orchestrator.activeRoute?.path, '/custom/applications');
    });
  });

  group('JobcenterMasterOrchestrator', () {
    test('exposes shared Bürgergeld, course, and appointment models', () {
      final orchestrator = JobcenterMasterOrchestrator();

      expect(orchestrator.benefitRequests, isNotEmpty);
      expect(orchestrator.courseRequests, isNotEmpty);
      expect(orchestrator.appointments, isNotEmpty);
      expect(
        orchestrator.benefitRequests.first.programNameDe,
        contains('Bürgergeld'),
      );
      expect(
        orchestrator.courseRequests.first.courseNameDe,
        contains('Integrationskurs'),
      );
      expect(
        orchestrator.appointments.first.officeNameDe,
        contains('Agentur für Arbeit'),
      );
    });

    test('searches German and Arabic and keeps section isolation', () {
      final orchestrator = JobcenterMasterOrchestrator()
        ..setQuery('Bürgergeld');

      expect(orchestrator.visibleEntries, isNotEmpty);
      expect(
        orchestrator.visibleEntries.every(
          (entry) => entry.section == JobcenterSection.overview,
        ),
        isTrue,
      );

      orchestrator
        ..setSection(JobcenterSection.consultationJobs)
        ..setQuery('دورة اللغة');

      expect(orchestrator.visibleEntries, isNotEmpty);
      expect(
        orchestrator.visibleEntries.every(
          (entry) => entry.section == JobcenterSection.consultationJobs,
        ),
        isTrue,
      );
    });

    test('switching sections clears stale search', () {
      final orchestrator = JobcenterMasterOrchestrator()
        ..setQuery('Bürgergeld');

      orchestrator.setSection(JobcenterSection.applicationsNotices);

      expect(orchestrator.query, isEmpty);
      expect(
        orchestrator.activeRoute?.id,
        'jobcenter-applications',
      );
    });
  });

  testWidgets(
    'master hub uses glass cards, safe scrolling, and explicit BiDi',
    (tester) async {
      final orchestrator = JobcenterMasterOrchestrator();

      await tester.pumpWidget(
        MaterialApp(
          home: LifeJobcenterEmploymentScreen(
            orchestrator: orchestrator,
          ),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(AppGlassCard), findsWidgets);

      final directions = tester
          .widgetList<Directionality>(find.byType(Directionality))
          .map((widget) => widget.textDirection)
          .toSet();
      expect(directions, contains(TextDirection.rtl));
      expect(directions, contains(TextDirection.ltr));

      expect(
        find.text('Jobcenter & Agentur für Arbeit'),
        findsOneWidget,
      );
      expect(find.textContaining('Bürgergeld'), findsWidgets);
    },
  );
}
