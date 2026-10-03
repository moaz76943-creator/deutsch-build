import 'verb_models.dart';

abstract final class VerbConjugationFactory {
  static const Map<GermanPronoun, String> _habenPresent = {
    GermanPronoun.ich: 'habe',
    GermanPronoun.du: 'hast',
    GermanPronoun.erSieEs: 'hat',
    GermanPronoun.wir: 'haben',
    GermanPronoun.ihr: 'habt',
    GermanPronoun.sieSie: 'haben',
  };

  static const Map<GermanPronoun, String> _seinPresent = {
    GermanPronoun.ich: 'bin',
    GermanPronoun.du: 'bist',
    GermanPronoun.erSieEs: 'ist',
    GermanPronoun.wir: 'sind',
    GermanPronoun.ihr: 'seid',
    GermanPronoun.sieSie: 'sind',
  };

  static VerbItem build(VerbLexemeSpec spec) {
    _validateForms(spec.infinitive, spec.presentForms, VerbTense.praesens);
    _validateForms(
      spec.infinitive,
      spec.preteriteForms,
      VerbTense.praeteritum,
    );
    if (spec.participle.trim().isEmpty) {
      throw StateError('${spec.infinitive} has an empty Partizip II');
    }

    final auxiliaryForms = switch (spec.auxiliary) {
      PerfectAuxiliary.haben => _habenPresent,
      PerfectAuxiliary.sein => _seinPresent,
    };
    final perfektForms = <GermanPronoun, String>{
      for (final pronoun in GermanPronoun.values)
        pronoun: '${auxiliaryForms[pronoun]} ${spec.participle}',
    };

    return VerbItem(
      infinitive: spec.infinitive,
      meaningAr: spec.meaningAr,
      kind: spec.kind,
      presentEmphasisTokens: List.unmodifiable(spec.presentEmphasisTokens),
      tables: Map.unmodifiable({
        VerbTense.praesens: VerbConjugationTable(
          tense: VerbTense.praesens,
          forms: Map.unmodifiable(spec.presentForms),
        ),
        VerbTense.praeteritum: VerbConjugationTable(
          tense: VerbTense.praeteritum,
          forms: Map.unmodifiable(spec.preteriteForms),
        ),
        VerbTense.perfekt: VerbConjugationTable(
          tense: VerbTense.perfekt,
          forms: Map.unmodifiable(perfektForms),
          auxiliary: spec.auxiliary,
          participle: spec.participle,
        ),
      }),
    );
  }

  static List<VerbTextSegment> emphasisFor({
    required VerbItem verb,
    required VerbTense tense,
    required GermanPronoun pronoun,
  }) {
    final form = verb.tableFor(tense).formFor(pronoun);
    if (tense != VerbTense.praesens || verb.presentEmphasisTokens.isEmpty) {
      return <VerbTextSegment>[
        VerbTextSegment(form, emphasized: false),
      ];
    }

    var bestIndex = -1;
    var bestToken = '';
    for (final token in verb.presentEmphasisTokens) {
      final index = form.toLowerCase().indexOf(token.toLowerCase());
      if (index >= 0 && (bestIndex < 0 || index < bestIndex)) {
        bestIndex = index;
        bestToken = form.substring(index, index + token.length);
      }
    }
    if (bestIndex < 0) {
      return <VerbTextSegment>[
        VerbTextSegment(form, emphasized: false),
      ];
    }

    return <VerbTextSegment>[
      if (bestIndex > 0)
        VerbTextSegment(form.substring(0, bestIndex), emphasized: false),
      VerbTextSegment(bestToken, emphasized: true),
      if (bestIndex + bestToken.length < form.length)
        VerbTextSegment(
          form.substring(bestIndex + bestToken.length),
          emphasized: false,
        ),
    ];
  }

  static void _validateForms(
    String infinitive,
    Map<GermanPronoun, String> forms,
    VerbTense tense,
  ) {
    if (forms.length != GermanPronoun.values.length) {
      throw StateError('$infinitive has incomplete ${tense.label} forms');
    }
    for (final pronoun in GermanPronoun.values) {
      final form = forms[pronoun];
      if (form == null || form.trim().isEmpty) {
        throw StateError(
          '$infinitive has no ${tense.label} form for ${pronoun.label}',
        );
      }
    }
  }
}
