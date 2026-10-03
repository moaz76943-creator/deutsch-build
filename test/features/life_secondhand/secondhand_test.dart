import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_secondhand/donation_and_social_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_secondhand/flea_market_and_ads_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_secondhand/secondhand_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_secondhand/secondhand_models.dart';
import 'package:deutsch_bilarabi/features/life_secondhand/secondhand_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SecondhandMasterOrchestrator', () {
    test('defaults to flea markets and searches locally', () {
      final orchestrator = SecondhandMasterOrchestrator();

      expect(orchestrator.domain, SecondhandDomain.fleaMarketsAndAds);
      expect(
        orchestrator.visibleEntries.any(
          (entry) => entry.id == 'flea-market-stall',
        ),
        isTrue,
      );

      orchestrator.setQuery('Tapeziertisch');

      expect(orchestrator.visibleEntries, hasLength(1));
      expect(orchestrator.visibleEntries.single.id, 'flea-market-stall');
    });

    test('switches domains and exposes friendly VB bargaining guidance', () {
      final orchestrator = SecondhandMasterOrchestrator();

      orchestrator
        ..setDomain(SecondhandDomain.donationAndSocialStores)
        ..setQuery('Schuhe');

      expect(orchestrator.domain, SecondhandDomain.donationAndSocialStores);
      expect(orchestrator.visibleEntries, hasLength(1));
      expect(
        orchestrator.visibleEntries.single.id,
        'donation-clothing-container',
      );
      expect(
        orchestrator.bargainingTips.any(
          (tip) => tip.german.contains('Verhandlungsbasis'),
        ),
        isTrue,
      );
      expect(
        orchestrator.bargainingTips.any(
          (tip) => tip.german.contains('Wie wäre es mit'),
        ),
        isTrue,
      );
    });
  });

  test('sub-agents cover markets, classifieds, containers, and social stores', () {
    const flea = FleaMarketAndAdsSubAgent();
    const donation = DonationAndSocialSubAgent();

    expect(
      flea.entries.map((entry) => entry.id),
      containsAll(<String>[
        'flea-market-stall',
        'flea-market-negotiation',
        'local-ad-posting',
      ]),
    );
    expect(
      donation.entries.map((entry) => entry.id),
      containsAll(<String>[
        'donation-clothing-container',
        'social-store-locate',
        'social-store-visit',
      ]),
    );
  });

  testWidgets(
    'hub uses glass cards, safe scrolling, explicit BiDi, filters, and tips bar',
    (tester) async {
      final orchestrator = SecondhandMasterOrchestrator();

      await tester.pumpWidget(
        MaterialApp(
          home: SecondhandMasterHub(orchestrator: orchestrator),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(AppGlassCard), findsWidgets);
      expect(
        find.byKey(const ValueKey<String>('secondhand-bargaining-bar')),
        findsOneWidget,
      );

      final directions = tester
          .widgetList<Directionality>(find.byType(Directionality))
          .map((widget) => widget.textDirection)
          .toSet();
      expect(directions, contains(TextDirection.ltr));
      expect(directions, contains(TextDirection.rtl));

      expect(find.textContaining('Verhandlungsbasis'), findsWidgets);

      await tester.tap(
        find.byKey(
          const ValueKey<String>(
            'secondhand-domain-donationAndSocialStores',
          ),
        ),
      );
      await tester.pump();

      expect(orchestrator.domain, SecondhandDomain.donationAndSocialStores);
      expect(find.textContaining('Sozialkaufhaus'), findsWidgets);
      expect(find.textContaining('Rotes Kreuz'), findsWidgets);
      expect(find.textContaining('Schuhe paarweise'), findsWidgets);
    },
  );
}
