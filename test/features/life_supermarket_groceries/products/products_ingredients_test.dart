import 'package:deutsch_bilarabi/features/life_supermarket_groceries/products/products_ingredients_models.dart';
import 'package:deutsch_bilarabi/features/life_supermarket_groceries/products/products_ingredients_sub_agent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductsIngredientsSubAgent', () {
    test('covers aisle and shelf location questions', () {
      const agent = ProductsIngredientsSubAgent();

      expect(
        agent.phrases.any(
          (phrase) =>
              phrase.kind == ProductInquiryKind.location &&
              phrase.german.contains('Gang'),
        ),
        isTrue,
      );
      expect(
        agent.search('Regal').any(
          (phrase) => phrase.german.contains('Regal'),
        ),
        isTrue,
      );
    });

    test('covers allergy and ingredient checks without assuming certification',
        () {
      const agent = ProductsIngredientsSubAgent();
      final corpus = agent.phrases
          .expand(
            (phrase) => <String>[
              phrase.topicDe,
              phrase.german,
              phrase.arabic,
              ...phrase.keywords,
            ],
          )
          .join(' ');

      expect(corpus, contains('Vegan'));
      expect(corpus, contains('glutenfrei'));
      expect(corpus, contains('Halal'));
      expect(corpus, contains('Schweinefleisch'));
      expect(corpus, contains('Allergene'));
      expect(corpus, contains('Zutatenliste'));
      expect(corpus, contains('zertifiziert'));
    });

    test('covers cheese and fresh meat counter by weight', () {
      const agent = ProductsIngredientsSubAgent();

      final freshCounter = agent.phrases.where(
        (phrase) => phrase.kind == ProductInquiryKind.freshCounter,
      );

      expect(freshCounter.length, greaterThanOrEqualTo(3));
      expect(
        freshCounter.map((phrase) => phrase.german).join(' '),
        allOf(
          contains('Frischetheke'),
          contains('Gramm'),
          contains('Käse'),
        ),
      );
    });

    test('search is bilingual and diacritic tolerant', () {
      const agent = ProductsIngredientsSubAgent();

      expect(agent.search('مكونات'), isNotEmpty);
      expect(agent.search('schweinefleisch'), isNotEmpty);
      expect(agent.search('glutenfrei'), isNotEmpty);
    });
  });
}
