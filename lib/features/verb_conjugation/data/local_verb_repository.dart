import '../domain/verb_conjugation_factory.dart';
import '../domain/verb_models.dart';
import '../domain/verb_repository.dart';
import 'common_verb_seeds.dart';

class LocalVerbRepository implements VerbRepository {
  LocalVerbRepository() : _verbs = _buildValidatedBank();

  final List<VerbItem> _verbs;

  @override
  List<VerbItem> get commonVerbs => _verbs;

  @override
  VerbItem? byInfinitive(String infinitive) {
    final normalized = infinitive.trim().toLowerCase();
    for (final verb in _verbs) {
      if (verb.infinitive.toLowerCase() == normalized) return verb;
    }
    return null;
  }

  static List<VerbItem> _buildValidatedBank() {
    final seeds = buildCommonVerbSeeds();
    if (seeds.length != 50) {
      throw StateError('common verb bank must contain exactly 50 verbs');
    }
    final verbs = seeds.map(VerbConjugationFactory.build).toList(growable: false);
    final unique = verbs.map((verb) => verb.infinitive).toSet();
    if (unique.length != verbs.length) {
      throw StateError('common verb bank contains duplicate infinitives');
    }
    return List.unmodifiable(verbs);
  }
}
