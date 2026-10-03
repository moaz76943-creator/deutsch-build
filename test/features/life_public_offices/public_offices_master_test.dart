import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_public_offices/public_office_models.dart';
import 'package:deutsch_bilarabi/features/life_public_offices/public_office_routes.dart';
import 'package:deutsch_bilarabi/features/life_public_offices/public_offices_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_public_offices/public_offices_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PublicOfficesMasterOrchestrator', () {
    test('exposes the two module routes', () {
      final orchestrator = PublicOfficesMasterOrchestrator();

      expect(
        orchestrator.visibleRoutes.map((route) => route.id),
        containsAll(<PublicOfficeRouteId>[
          PublicOfficeRouteId.anmeldungAppointments,
          PublicOfficeRouteId.formsDocuments,
        ]),
      );
    });

    test('filters routes by authority', () {
      final orchestrator = PublicOfficesMasterOrchestrator();

      orchestrator.setOffice(PublicOfficeType.buergeramt);

      expect(orchestrator.visibleRoutes, isNotEmpty);
      expect(
        orchestrator.visibleRoutes.every(
          (route) => route.supportedOffices.contains(PublicOfficeType.buergeramt),
        ),
        isTrue,
      );
    });

    test('search works with German and Arabic terms', () {
      final orchestrator = PublicOfficesMasterOrchestrator();

      orchestrator.setQuery('Anmeldung');
      expect(
        orchestrator.visibleRoutes.any(
          (route) => route.id == PublicOfficeRouteId.anmeldungAppointments,
        ),
        isTrue,
      );

      orchestrator.setQuery('استمارة');
      expect(
        orchestrator.visibleRoutes.any(
          (route) => route.id == PublicOfficeRouteId.formsDocuments,
        ),
        isTrue,
      );
    });

    test('accepts injected module dependencies', () {
      const dependency = _FakeDependency();
      final orchestrator = PublicOfficesMasterOrchestrator(
        dependencies: const <PublicOfficeModuleDependency>[dependency],
      );

      expect(orchestrator.documents, hasLength(1));
      expect(orchestrator.documents.single.titleDe, 'Testdokument');
    });
  });

  testWidgets('master hub uses glass cards and safe scrolling', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PublicOfficesMasterHub()),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Behörden & Verwaltung'), findsOneWidget);
    expect(find.byKey(const ValueKey('public-office-search')), findsOneWidget);
  });
}

final class _FakeDependency implements PublicOfficeModuleDependency {
  const _FakeDependency();

  @override
  PublicOfficeRouteDescriptor get route => PublicOfficeRoutes.documents;

  @override
  Iterable<OfficialDocument> get documents => const <OfficialDocument>[
        OfficialDocument(
          id: 'test-document',
          titleDe: 'Testdokument',
          titleAr: 'وثيقة اختبار',
          kind: OfficialDocumentKind.applicationForm,
          applicableOffices: <PublicOfficeType>[PublicOfficeType.buergeramt],
        ),
      ];
}
