import 'deck_models.dart';

/// Pure-Dart ingestion boundary for directed lexical decks.
abstract interface class DeckParserContract {
  ParsedDeck parse(
    String jsonText, {
    required String deckId,
    required String sourceLanguage,
    required String targetLanguage,
  });
}
