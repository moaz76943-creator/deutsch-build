import '../language/language_text_normalizer.dart';
import '../models/verb_conjugation.dart';

/// Language-neutral verb lookup over an explicitly supplied row set.
///
/// Production callers must source rows from an admitted runtime repository.
/// This engine deliberately owns no embedded/generated corpus fallback.
final class VerbIndex {
  VerbIndex.fromRows({
    required LanguageTextNormalizer textNormalizer,
    required Iterable<VerbConjugation> rows,
  }) : _textNormalizer = textNormalizer {
    for (final row in rows) {
      _byForm
          .putIfAbsent(
            _textNormalizer.answer(row.form),
            () => <VerbConjugation>[],
          )
          .add(row);
      _byInfinitive
          .putIfAbsent(
            _textNormalizer.answer(row.infinitive),
            () => <VerbConjugation>[],
          )
          .add(row);
      _byGroup.putIfAbsent(row.group, () => <String>{}).add(row.infinitive);
    }
    _infinitives = _byInfinitive.values
        .expand((items) => items)
        .map((row) => row.infinitive)
        .toSet()
        .toList(growable: false);
  }

  final LanguageTextNormalizer _textNormalizer;
  final Map<String, List<VerbConjugation>> _byForm =
      <String, List<VerbConjugation>>{};
  final Map<String, List<VerbConjugation>> _byInfinitive =
      <String, List<VerbConjugation>>{};
  final Map<String, Set<String>> _byGroup = <String, Set<String>>{};
  late final List<String> _infinitives;
  late final Map<String, List<String>> _groups = <String, List<String>>{
    for (final entry in _byGroup.entries)
      entry.key: entry.value.toList(growable: false),
  };

  List<VerbConjugation> lookup(String query) =>
      _byForm[_textNormalizer.answer(query)] ?? const <VerbConjugation>[];

  List<String> infinitivesFor(String query) =>
      lookup(query).map((row) => row.infinitive).toSet().toList(growable: false);

  List<VerbConjugation> rowsFor(String infinitive) =>
      _byInfinitive[_textNormalizer.answer(infinitive)] ??
      const <VerbConjugation>[];

  List<String> get infinitives => _infinitives;

  Map<String, List<String>> get groups => _groups;

  bool containsForm(String query) => lookup(query).isNotEmpty;
}
