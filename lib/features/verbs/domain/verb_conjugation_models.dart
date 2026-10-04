enum VerbPerson { ich, du, erSieEs, wir, ihr, sieSie }

extension VerbPersonLabel on VerbPerson {
  String get label => switch (this) {
        VerbPerson.ich => 'ich',
        VerbPerson.du => 'du',
        VerbPerson.erSieEs => 'er / sie / es',
        VerbPerson.wir => 'wir',
        VerbPerson.ihr => 'ihr',
        VerbPerson.sieSie => 'sie / Sie',
      };
}

final class VerbTenseTable {
  VerbTenseTable({
    required this.key,
    required this.label,
    required Map<VerbPerson, String> forms,
  }) : forms = Map<VerbPerson, String>.unmodifiable(forms) {
    if (key.trim().isEmpty || label.trim().isEmpty) {
      throw ArgumentError('Verb tense key and label must not be empty.');
    }
    for (final entry in this.forms.entries) {
      if (entry.value.trim().isEmpty) {
        throw ArgumentError(
          'Verb form for ' + entry.key.label + ' must not be empty.',
        );
      }
    }
  }

  final String key;
  final String label;
  final Map<VerbPerson, String> forms;

  String formFor(VerbPerson person) => forms[person] ?? '—';
}

final class VerbConjugation {
  VerbConjugation({
    required this.id,
    required this.infinitive,
    required this.meaning,
    required List<VerbTenseTable> tenses,
    this.pastParticiple,
    this.auxiliary,
    this.isSeparable = false,
  }) : tenses = List<VerbTenseTable>.unmodifiable(tenses) {
    if (id.trim().isEmpty ||
        infinitive.trim().isEmpty ||
        meaning.trim().isEmpty) {
      throw ArgumentError(
        'Verb id, infinitive and meaning must not be empty.',
      );
    }
    if (this.tenses.isEmpty) {
      throw ArgumentError('A verb must provide at least one tense table.');
    }
  }

  final String id;
  final String infinitive;
  final String meaning;
  final List<VerbTenseTable> tenses;
  final String? pastParticiple;
  final String? auxiliary;
  final bool isSeparable;

  String get searchText => <String>[
        infinitive,
        meaning,
        if (pastParticiple != null) pastParticiple!,
        if (auxiliary != null) auxiliary!,
      ].join(' ');

  String? get perfektSummary {
    final aux = auxiliary?.trim() ?? '';
    final participle = pastParticiple?.trim() ?? '';
    if (aux.isEmpty || participle.isEmpty) return null;
    return aux + ' ' + participle;
  }
}

final class VerbSearchHit {
  const VerbSearchHit({
    required this.verb,
    required this.score,
  });

  final VerbConjugation verb;
  final double score;
}
