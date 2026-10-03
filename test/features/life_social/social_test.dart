import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_social/neighborhood_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_social/occasions_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_social/social_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_social/social_models.dart';
import 'package:deutsch_bilarabi/features/life_social/social_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SocialMasterOrchestrator', () {
    test('defaults to formal neighborhood etiquette and filters locally', () {
      final orchestrator = SocialMasterOrchestrator();

      expect(orchestrator.tone, SocialTone.sie);
      expect(orchestrator.category, SocialCategory.neighborhood);
      expect(
        orchestrator.visiblePhrases.any(
          (phrase) => phrase.id == 'neighborhood-quiet-hours',
        ),
        isTrue,
      );

      orchestrator.setQuery('Hausordnung');

      expect(orchestrator.visiblePhrases, hasLength(1));
      expect(orchestrator.visiblePhrases.single.id, 'neighborhood-house-rules');
    });

    test('tone and category switches preserve polite intent', () {
      final orchestrator = SocialMasterOrchestrator();

      orchestrator
        ..setTone(SocialTone.du)
        ..setCategory(SocialCategory.occasions);

      expect(orchestrator.tone, SocialTone.du);
      expect(orchestrator.category, SocialCategory.occasions);
      expect(
        orchestrator.quickResponses,
        contains('Danke dir, sehr freundlich.'),
      );
      expect(
        orchestrator.visiblePhrases.any(
          (phrase) => phrase.id == 'occasion-recovery',
        ),
        isTrue,
      );
    });
  });

  test('sub-agents expose the required wholesome everyday domains', () {
    const neighborhood = NeighborhoodSubAgent();
    const occasions = OccasionsSubAgent();

    expect(
      neighborhood.phrases.map((phrase) => phrase.id),
      containsAll(<String>[
        'neighborhood-quiet-hours',
        'neighborhood-package-courtesy',
        'neighborhood-house-rules',
      ]),
    );
    expect(
      occasions.phrases.map((phrase) => phrase.id),
      containsAll(<String>[
        'occasion-birth',
        'occasion-graduation',
        'occasion-recovery',
        'occasion-condolence',
        'occasion-decline-invitation',
      ]),
    );
  });

  testWidgets(
    'hub uses glass cards, safe scrolling, explicit BiDi, and live controls',
    (tester) async {
      final orchestrator = SocialMasterOrchestrator();

      await tester.pumpWidget(
        MaterialApp(
          home: SocialMasterHub(orchestrator: orchestrator),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(AppGlassCard), findsWidgets);

      final directions = tester
          .widgetList<Directionality>(find.byType(Directionality))
          .map((widget) => widget.textDirection)
          .toSet();
      expect(directions, contains(TextDirection.ltr));
      expect(directions, contains(TextDirection.rtl));

      await tester.tap(find.byKey(const ValueKey<String>('social-tone-du')));
      await tester.pump();

      expect(orchestrator.tone, SocialTone.du);
      expect(find.text('Danke dir, sehr freundlich.'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('social-category-occasions')),
      );
      await tester.pump();

      expect(orchestrator.category, SocialCategory.occasions);
      expect(
        find.text('Gute Besserung! Ich wünsche dir eine schnelle Genesung.'),
        findsOneWidget,
      );
    },
  );
}
