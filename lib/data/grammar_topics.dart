import '../models/grammar.dart';
import 'canonical_grammar_catalog.dart';

/// Compatibility bridge for legacy callers.
///
/// The only authored grammar source is [CanonicalGrammarCatalog]. Production
/// runtime compiles that source into SQLite through CanonicalGrammarCompiler.
@Deprecated('Use CanonicalGrammarCatalog or GrammarHubRepository.')
abstract final class GrammarTopicsData {
  static const List<GrammarTopic> allTopics = CanonicalGrammarCatalog.allTopics;
}
