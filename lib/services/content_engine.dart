import '../core/content_contract.dart';

/// Neutral runtime boundary between learning logic and a physical content source.
/// Language-specific source selection belongs to the selected language pack.
abstract interface class ContentSource<T extends LearningContent> {
  Iterable<T> get items;
}

class ContentEngine<T extends LearningContent> {
  const ContentEngine(this._source);

  final ContentSource<T> _source;

  Iterable<T> get items => _source.items;

  T? byId(String id) {
    final target = id.trim();
    if (target.isEmpty) return null;
    for (final item in _source.items) {
      if (item.id == target) return item;
    }
    return null;
  }
}
