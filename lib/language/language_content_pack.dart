import '../models/content.dart';
import '../services/verb_index.dart';

/// Runtime content boundary owned by the selected learning language.
///
/// The application core consumes the resulting catalogue and indexes without
/// knowing which language-specific source assembled them. A future language
/// can provide a different implementation without changing the composition
/// root's dependency shape.
abstract interface class LanguageContentPack {
  List<ContentItem> get items;
  VerbIndex get verbIndex;
}
