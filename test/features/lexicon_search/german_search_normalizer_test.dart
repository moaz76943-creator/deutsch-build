import 'package:deutsch_bilarabi/features/lexicon_search/domain/german_search_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes German umlauts and eszett into searchable variants', () {
    expect(
      GermanSearchNormalizer.variants('  Füße  '),
      containsAll(<String>{'füsse', 'fuesse', 'fusse'}),
    );
    expect(
      GermanSearchNormalizer.variants('Öl'),
      containsAll(<String>{'öl', 'oel', 'ol'}),
    );
    expect(
      GermanSearchNormalizer.variants('Äpfel'),
      containsAll(<String>{'äpfel', 'aepfel', 'apfel'}),
    );
  });

  test('normalization is case insensitive and collapses punctuation', () {
    expect(
      GermanSearchNormalizer.normalize('  ÜBER, Straße!  '),
      'über strasse',
    );
  });
}
