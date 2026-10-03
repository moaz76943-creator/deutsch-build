import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/life_shopping/application/shopping_agents.dart';
import 'package:deutsch_bilarabi/features/life_shopping/application/shopping_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_shopping/domain/shopping_models.dart';
import 'package:deutsch_bilarabi/features/life_shopping/presentation/shopping_master_screen.dart';

void main() {
  const grocery = GroceryShoppingAgent();
  const returns = ReturnWarrantyShoppingAgent();

  group('GroceryShoppingAgent', () {
    test('covers ingredients, plant-based alternatives, weights and checkout',
        () {
      final all = grocery.phrases;
      final german = all.map((item) => item.german).join(' ').toLowerCase();

      expect(all.length, greaterThanOrEqualTo(12));
      expect(german, contains('zutaten'));
      expect(german, contains('pflanzliche'));
      expect(german, contains('gramm'));
      expect(german, contains('kasse'));
    });

    test('provides content at A1/A2, B1 and B2', () {
      for (final level in ShoppingLevel.values) {
        expect(
          grocery.phrases.where((item) => item.level == level),
          isNotEmpty,
        );
      }
    });

    test('search is bilingual, normalized and level-aware', () {
      expect(
        grocery.search('  PFLANZLICHE  '),
        everyElement(
          isA<ShoppingPhrase>().having(
            (item) => item.agent,
            'agent',
            ShoppingAgentType.grocery,
          ),
        ),
      );
      expect(
        grocery.search('مكونات'),
        isNotEmpty,
      );
      expect(
        grocery.search('kasse', level: ShoppingLevel.a1a2),
        everyElement(
          isA<ShoppingPhrase>().having(
            (item) => item.level,
            'level',
            ShoppingLevel.a1a2,
          ),
        ),
      );
    });
  });

  group('ReturnWarrantyShoppingAgent', () {
    test('covers defective items, receipt or invoice and polite complaints',
        () {
      final all = returns.phrases;
      final german = all.map((item) => item.german).join(' ').toLowerCase();

      expect(all.length, greaterThanOrEqualTo(12));
      expect(german, anyOf(contains('defekt'), contains('mangel')));
      expect(german, anyOf(contains('rechnung'), contains('kassenbon')));
      expect(german, contains('reklamieren'));
      expect(german, contains('bitte'));
    });

    test('keeps return and warranty content practical and wholesome', () {
      final combined = returns.phrases
          .expand(
            (item) => <String>[
              item.german,
              item.arabic,
              item.usageArabic,
              ...item.searchTags,
            ],
          )
          .join(' ')
          .toLowerCase();

      for (final blocked in <String>[
        'alkohol',
        'bier',
        'wein',
        'nachtclub',
        'musik',
        'party',
      ]) {
        expect(combined, isNot(contains(blocked)));
      }
    });
  });

  group('ShoppingMasterOrchestrator', () {
    test('aggregates both sub-agents and filters by CEFR shopping level', () {
      final orchestrator = ShoppingMasterOrchestrator(
        groceryAgent: grocery,
        returnWarrantyAgent: returns,
      );
      addTearDown(orchestrator.dispose);

      expect(
        orchestrator.results.map((item) => item.agent).toSet(),
        <ShoppingAgentType>{
          ShoppingAgentType.grocery,
          ShoppingAgentType.returnWarranty,
        },
      );

      orchestrator.setLevel(ShoppingLevel.b2);

      expect(orchestrator.activeLevel, ShoppingLevel.b2);
      expect(
        orchestrator.results.every((item) => item.level == ShoppingLevel.b2),
        isTrue,
      );
    });

    test('searches across both sub-agents and can clear the query', () {
      final orchestrator = ShoppingMasterOrchestrator(
        groceryAgent: grocery,
        returnWarrantyAgent: returns,
      );
      addTearDown(orchestrator.dispose);

      orchestrator.setQuery('Rechnung');

      expect(orchestrator.query, 'Rechnung');
      expect(orchestrator.results, isNotEmpty);
      expect(
        orchestrator.results.every(
          (item) => item.agent == ShoppingAgentType.returnWarranty,
        ),
        isTrue,
      );

      orchestrator.clearSearch();

      expect(orchestrator.query, isEmpty);
      expect(orchestrator.results, isNotEmpty);
    });

    test('panic bar exposes immediate phrases from both agents', () {
      final orchestrator = ShoppingMasterOrchestrator(
        groceryAgent: grocery,
        returnWarrantyAgent: returns,
      );
      addTearDown(orchestrator.dispose);

      expect(orchestrator.isPanicBarOpen, isFalse);

      orchestrator.togglePanicBar();

      expect(orchestrator.isPanicBarOpen, isTrue);
      expect(orchestrator.panicPhrases, isNotEmpty);
      expect(
        orchestrator.panicPhrases.map((item) => item.agent).toSet(),
        <ShoppingAgentType>{
          ShoppingAgentType.grocery,
          ShoppingAgentType.returnWarranty,
        },
      );
      expect(
        orchestrator.panicPhrases.every((item) => item.isPanicPhrase),
        isTrue,
      );
    });

    test('can reset level and query without mutating source agents', () {
      final orchestrator = ShoppingMasterOrchestrator(
        groceryAgent: grocery,
        returnWarrantyAgent: returns,
      );
      addTearDown(orchestrator.dispose);
      final sourceCount = grocery.phrases.length + returns.phrases.length;

      orchestrator.setLevel(ShoppingLevel.b1);
      orchestrator.setQuery('bitte');
      orchestrator.resetFilters();

      expect(orchestrator.activeLevel, isNull);
      expect(orchestrator.query, isEmpty);
      expect(orchestrator.results, hasLength(sourceCount));
    });
  });

  test('ShoppingMasterScreen is constructible from the orchestrator', () {
    final orchestrator = ShoppingMasterOrchestrator(
      groceryAgent: grocery,
      returnWarrantyAgent: returns,
    );
    addTearDown(orchestrator.dispose);

    final screen = ShoppingMasterScreen(orchestrator: orchestrator);

    expect(screen, isA<ShoppingMasterScreen>());
  });
}
