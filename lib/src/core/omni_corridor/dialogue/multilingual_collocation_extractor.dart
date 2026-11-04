/// Task 1934: Collocation extractor identifying natural word pairings
class MultilingualCollocationExtractor {
  List<String> extractCollocations(String text) => text.split(' ').take(2).toList();
}
