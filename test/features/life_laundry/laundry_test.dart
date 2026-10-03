import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_laundry/dry_cleaning_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_laundry/laundry_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_laundry/laundry_models.dart';
import 'package:deutsch_bilarabi/features/life_laundry/laundry_screen.dart';
import 'package:deutsch_bilarabi/features/life_laundry/self_service_laundromat_sub_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LaundryMasterOrchestrator', () {
    test('defaults to self-service, filters locally, and switches domains', () {
      final orchestrator = LaundryMasterOrchestrator();

      expect(orchestrator.domain, LaundryDomain.selfServiceLaundromat);
      expect(
        orchestrator.visiblePhrases.any(
          (phrase) => phrase.id == 'laundromat-token-machine',
        ),
        isTrue,
      );

      orchestrator.setQuery('Waschmarken');

      expect(orchestrator.visiblePhrases, hasLength(1));
      expect(orchestrator.visiblePhrases.single.id, 'laundromat-token-machine');

      orchestrator
        ..clearSearch()
        ..setDomain(LaundryDomain.professionalCleaning);

      expect(orchestrator.domain, LaundryDomain.professionalCleaning);
      expect(
        orchestrator.visiblePhrases.any(
          (phrase) => phrase.id == 'cleaning-pickup-receipt',
        ),
        isTrue,
      );
    });

    test('fabric care guide exposes practical washing and cleaning symbols', () {
      final orchestrator = LaundryMasterOrchestrator();

      expect(orchestrator.fabricCareSymbols.length, greaterThanOrEqualTo(5));
      expect(
        orchestrator.fabricCareSymbols.any(
          (symbol) => symbol.id == 'wash-40',
        ),
        isTrue,
      );
      expect(
        orchestrator.fabricCareSymbols.any(
          (symbol) => symbol.id == 'professional-clean-p',
        ),
        isTrue,
      );
      expect(
        orchestrator.fabricCareSymbols.every(
          (symbol) => symbol.german.isNotEmpty && symbol.arabic.isNotEmpty,
        ),
        isTrue,
      );
    });
  });

  test('sub-agents cover laundromat and professional textile-cleaning tasks', () {
    const selfService = SelfServiceLaundromatSubAgent();
    const dryCleaning = DryCleaningSubAgent();

    expect(
      selfService.phrases.map((phrase) => phrase.id),
      containsAll(<String>[
        'laundromat-token-machine',
        'laundromat-programs',
        'laundromat-dryer-time',
      ]),
    );
    expect(
      dryCleaning.phrases.map((phrase) => phrase.id),
      containsAll(<String>[
        'cleaning-suit-delivery',
        'cleaning-stain-treatment',
        'cleaning-shirt-ironing',
        'cleaning-pickup-receipt',
      ]),
    );
  });

  testWidgets(
    'hub uses glass cards, safe scrolling, explicit BiDi, domains and care guide',
    (tester) async {
      final orchestrator = LaundryMasterOrchestrator();

      await tester.pumpWidget(
        MaterialApp(
          home: LaundryMasterHub(orchestrator: orchestrator),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(AppGlassCard), findsWidgets);
      expect(
        find.byKey(const ValueKey<String>('laundry-care-symbols-guide')),
        findsOneWidget,
      );

      final directions = tester
          .widgetList<Directionality>(find.byType(Directionality))
          .map((widget) => widget.textDirection)
          .toSet();
      expect(directions, contains(TextDirection.ltr));
      expect(directions, contains(TextDirection.rtl));

      expect(find.textContaining('Waschmarken'), findsWidgets);

      await tester.tap(
        find.byKey(
          const ValueKey<String>('laundry-domain-professionalCleaning'),
        ),
      );
      await tester.pump();

      expect(orchestrator.domain, LaundryDomain.professionalCleaning);
      expect(find.textContaining('Chemische Reinigung'), findsWidgets);

      final search = find.byKey(const ValueKey<String>('laundry-search'));
      await tester.enterText(search, 'Abholschein');
      await tester.pump();

      expect(orchestrator.visiblePhrases, hasLength(1));
      expect(orchestrator.visiblePhrases.single.id, 'cleaning-pickup-receipt');
      expect(find.textContaining('Abholschein'), findsWidgets);
    },
  );
}
