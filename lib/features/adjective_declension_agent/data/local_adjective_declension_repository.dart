import '../domain/adjective_declension_models.dart';
import '../domain/adjective_declension_repository.dart';

final class LocalAdjectiveDeclensionRepository
    implements AdjectiveDeclensionRepository {
  LocalAdjectiveDeclensionRepository() : _exercises = _buildExerciseBank();

  final List<AdjectiveExerciseItem> _exercises;

  @override
  Future<List<AdjectiveExerciseItem>> getExercises({
    DeclensionType? type,
  }) async {
    final selected = type == null
        ? _exercises
        : _exercises
            .where((item) => item.declensionType == type)
            .toList(growable: false);
    return List<AdjectiveExerciseItem>.unmodifiable(selected);
  }

  @override
  Future<bool> checkAnswer(
    String exerciseId,
    String selectedEnding,
  ) async {
    final normalized = _normalizeEnding(selectedEnding);
    for (final item in _exercises) {
      if (item.id == exerciseId) {
        return normalized == item.correctEnding;
      }
    }
    return false;
  }

  static String _normalizeEnding(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) return '';
    return trimmed.startsWith('-') ? trimmed : '-$trimmed';
  }

  static List<AdjectiveExerciseItem> _buildExerciseBank() {
    final specs = <_ExerciseSpec>[
      const _ExerciseSpec(
        id: 'weak_nom_masc',
        sentence: 'Der ___ Mann arbeitet hier.',
        adjective: 'alt',
        type: DeclensionType.weak,
        grammaticalCase: GrammaticalCase.nominativ,
        gender: GrammaticalGender.maskulin,
        explanation:
            'بعد أداة المعرفة der في Nominativ للمذكر نستخدم التصريف الضعيف والنهاية -e.',
      ),
      const _ExerciseSpec(
        id: 'weak_nom_fem',
        sentence: 'Die ___ Tasche ist teuer.',
        adjective: 'neu',
        type: DeclensionType.weak,
        grammaticalCase: GrammaticalCase.nominativ,
        gender: GrammaticalGender.feminin,
        explanation:
            'بعد die في Nominativ للمؤنث تكون نهاية الصفة في التصريف الضعيف -e.',
      ),
      const _ExerciseSpec(
        id: 'weak_akk_masc',
        sentence: 'Ich sehe den ___ Nachbarn.',
        adjective: 'nett',
        type: DeclensionType.weak,
        grammaticalCase: GrammaticalCase.akkusativ,
        gender: GrammaticalGender.maskulin,
        explanation:
            'بعد den في Akkusativ للمذكر تكون نهاية الصفة الضعيفة -en.',
      ),
      const _ExerciseSpec(
        id: 'weak_dat_masc',
        sentence: 'Ich spreche mit dem ___ Nachbarn.',
        adjective: 'nett',
        type: DeclensionType.weak,
        grammaticalCase: GrammaticalCase.dativ,
        gender: GrammaticalGender.maskulin,
        explanation:
            'في Dativ بعد أداة معرفة تكون نهاية الصفة الضعيفة دائمًا -en.',
      ),
      const _ExerciseSpec(
        id: 'weak_dat_fem',
        sentence: 'Wir lernen in der ___ Schule.',
        adjective: 'neu',
        type: DeclensionType.weak,
        grammaticalCase: GrammaticalCase.dativ,
        gender: GrammaticalGender.feminin,
        explanation:
            'في Dativ بعد der للمؤنث نستخدم التصريف الضعيف والنهاية -en.',
      ),
      const _ExerciseSpec(
        id: 'weak_dat_plural',
        sentence: 'Wir reden mit den ___ Gästen.',
        adjective: 'freundlich',
        type: DeclensionType.weak,
        grammaticalCase: GrammaticalCase.dativ,
        gender: GrammaticalGender.plural,
        explanation:
            'في Dativ الجمع بعد den تكون نهاية الصفة الضعيفة -en.',
      ),
      const _ExerciseSpec(
        id: 'weak_gen_neut',
        sentence: 'Wegen des ___ Wetters bleiben wir zu Hause.',
        adjective: 'kalt',
        type: DeclensionType.weak,
        grammaticalCase: GrammaticalCase.genitiv,
        gender: GrammaticalGender.neutral,
        explanation:
            'بعد des في Genitiv للمحايد تكون نهاية الصفة الضعيفة -en.',
      ),
      const _ExerciseSpec(
        id: 'mixed_nom_masc',
        sentence: 'Ein ___ Mann hilft uns.',
        adjective: 'gut',
        type: DeclensionType.mixed,
        grammaticalCase: GrammaticalCase.nominativ,
        gender: GrammaticalGender.maskulin,
        explanation:
            'مع ein في Nominativ للمذكر لا تظهر علامة المذكر على الأداة، لذلك تحملها الصفة بالنهاية -er.',
      ),
      const _ExerciseSpec(
        id: 'mixed_nom_fem',
        sentence: 'Eine ___ Stadt liegt am Fluss.',
        adjective: 'schön',
        type: DeclensionType.mixed,
        grammaticalCase: GrammaticalCase.nominativ,
        gender: GrammaticalGender.feminin,
        explanation:
            'مع eine في Nominativ للمؤنث تكون نهاية الصفة في التصريف المختلط -e.',
      ),
      const _ExerciseSpec(
        id: 'mixed_nom_neut',
        sentence: 'Ein ___ Kind spielt draußen.',
        adjective: 'klein',
        type: DeclensionType.mixed,
        grammaticalCase: GrammaticalCase.nominativ,
        gender: GrammaticalGender.neutral,
        explanation:
            'مع ein في Nominativ للمحايد تحمل الصفة العلامة الظاهرة بالنهاية -es.',
      ),
      const _ExerciseSpec(
        id: 'mixed_akk_masc',
        sentence: 'Ich kaufe einen ___ Salat.',
        adjective: 'frisch',
        type: DeclensionType.mixed,
        grammaticalCase: GrammaticalCase.akkusativ,
        gender: GrammaticalGender.maskulin,
        explanation:
            'مع einen في Akkusativ للمذكر تكون نهاية الصفة المختلطة -en.',
      ),
      const _ExerciseSpec(
        id: 'mixed_akk_neut',
        sentence: 'Sie kauft ein ___ Auto.',
        adjective: 'neu',
        type: DeclensionType.mixed,
        grammaticalCase: GrammaticalCase.akkusativ,
        gender: GrammaticalGender.neutral,
        explanation:
            'مع ein في Akkusativ للمحايد تحمل الصفة علامة المحايد بالنهاية -es.',
      ),
      const _ExerciseSpec(
        id: 'mixed_dat_fem',
        sentence: 'Ich spreche mit einer ___ Kollegin.',
        adjective: 'neu',
        type: DeclensionType.mixed,
        grammaticalCase: GrammaticalCase.dativ,
        gender: GrammaticalGender.feminin,
        explanation:
            'في Dativ بعد einer تكون نهاية الصفة في التصريف المختلط -en.',
      ),
      const _ExerciseSpec(
        id: 'strong_nom_masc',
        sentence: '___ Kaffee schmeckt gut.',
        adjective: 'frisch',
        type: DeclensionType.strong,
        grammaticalCase: GrammaticalCase.nominativ,
        gender: GrammaticalGender.maskulin,
        explanation:
            'بدون أداة في Nominativ للمذكر تحمل الصفة علامة المذكر نفسها: -er.',
      ),
      const _ExerciseSpec(
        id: 'strong_nom_neut',
        sentence: '___ Wasser ist gesund.',
        adjective: 'kalt',
        type: DeclensionType.strong,
        grammaticalCase: GrammaticalCase.nominativ,
        gender: GrammaticalGender.neutral,
        explanation:
            'بدون أداة في Nominativ للمحايد تكون نهاية الصفة القوية -es.',
      ),
      const _ExerciseSpec(
        id: 'strong_akk_fem',
        sentence: 'Ich kaufe ___ Milch.',
        adjective: 'frisch',
        type: DeclensionType.strong,
        grammaticalCase: GrammaticalCase.akkusativ,
        gender: GrammaticalGender.feminin,
        explanation:
            'بدون أداة في Akkusativ للمؤنث تكون نهاية الصفة القوية -e.',
      ),
      const _ExerciseSpec(
        id: 'strong_dat_masc',
        sentence: 'Mit ___ Kaffee beginnt mein Tag.',
        adjective: 'heiß',
        type: DeclensionType.strong,
        grammaticalCase: GrammaticalCase.dativ,
        gender: GrammaticalGender.maskulin,
        explanation:
            'بدون أداة في Dativ للمذكر تحمل الصفة علامة الحالة بالنهاية -em.',
      ),
      const _ExerciseSpec(
        id: 'strong_dat_plural',
        sentence: 'Mit ___ Brötchen beginnt das Frühstück.',
        adjective: 'frisch',
        type: DeclensionType.strong,
        grammaticalCase: GrammaticalCase.dativ,
        gender: GrammaticalGender.plural,
        explanation:
            'بدون أداة في Dativ الجمع تكون نهاية الصفة القوية -en.',
      ),
      const _ExerciseSpec(
        id: 'strong_gen_fem',
        sentence: 'Trotz ___ Kälte gehen wir spazieren.',
        adjective: 'stark',
        type: DeclensionType.strong,
        grammaticalCase: GrammaticalCase.genitiv,
        gender: GrammaticalGender.feminin,
        explanation:
            'بدون أداة في Genitiv للمؤنث تكون نهاية الصفة القوية -er.',
      ),
    ];

    final exercises = specs
        .map(
          (spec) => AdjectiveExerciseItem(
            id: spec.id,
            sentenceWithBlank: spec.sentence,
            baseAdjective: spec.adjective,
            correctEnding: _endingFor(
              spec.type,
              spec.grammaticalCase,
              spec.gender,
            ),
            declensionType: spec.type,
            grammaticalCase: spec.grammaticalCase,
            grammaticalGender: spec.gender,
            explanationAr: spec.explanation,
          ),
        )
        .toList(growable: false);

    final ids = exercises.map((item) => item.id).toSet();
    if (ids.length != exercises.length) {
      throw StateError('adjective exercise bank contains duplicate ids');
    }
    return List<AdjectiveExerciseItem>.unmodifiable(exercises);
  }

  static String _endingFor(
    DeclensionType type,
    GrammaticalCase grammaticalCase,
    GrammaticalGender gender,
  ) {
    return switch (type) {
      DeclensionType.weak => _weakEnding(grammaticalCase, gender),
      DeclensionType.mixed => _mixedEnding(grammaticalCase, gender),
      DeclensionType.strong => _strongEnding(grammaticalCase, gender),
    };
  }

  static String _weakEnding(
    GrammaticalCase grammaticalCase,
    GrammaticalGender gender,
  ) {
    if (grammaticalCase == GrammaticalCase.dativ ||
        grammaticalCase == GrammaticalCase.genitiv) {
      return '-en';
    }
    if (grammaticalCase == GrammaticalCase.akkusativ &&
        gender == GrammaticalGender.maskulin) {
      return '-en';
    }
    if (gender == GrammaticalGender.plural) return '-en';
    return '-e';
  }

  static String _mixedEnding(
    GrammaticalCase grammaticalCase,
    GrammaticalGender gender,
  ) {
    if (grammaticalCase == GrammaticalCase.dativ ||
        grammaticalCase == GrammaticalCase.genitiv) {
      return '-en';
    }
    if (gender == GrammaticalGender.plural) return '-en';
    if (grammaticalCase == GrammaticalCase.akkusativ &&
        gender == GrammaticalGender.maskulin) {
      return '-en';
    }
    return switch (gender) {
      GrammaticalGender.maskulin => '-er',
      GrammaticalGender.feminin => '-e',
      GrammaticalGender.neutral => '-es',
      GrammaticalGender.plural => '-en',
    };
  }

  static String _strongEnding(
    GrammaticalCase grammaticalCase,
    GrammaticalGender gender,
  ) {
    return switch (grammaticalCase) {
      GrammaticalCase.nominativ => switch (gender) {
          GrammaticalGender.maskulin => '-er',
          GrammaticalGender.feminin => '-e',
          GrammaticalGender.neutral => '-es',
          GrammaticalGender.plural => '-e',
        },
      GrammaticalCase.akkusativ => switch (gender) {
          GrammaticalGender.maskulin => '-en',
          GrammaticalGender.feminin => '-e',
          GrammaticalGender.neutral => '-es',
          GrammaticalGender.plural => '-e',
        },
      GrammaticalCase.dativ => switch (gender) {
          GrammaticalGender.maskulin => '-em',
          GrammaticalGender.feminin => '-er',
          GrammaticalGender.neutral => '-em',
          GrammaticalGender.plural => '-en',
        },
      GrammaticalCase.genitiv => switch (gender) {
          GrammaticalGender.maskulin => '-en',
          GrammaticalGender.feminin => '-er',
          GrammaticalGender.neutral => '-en',
          GrammaticalGender.plural => '-er',
        },
    };
  }
}

final class _ExerciseSpec {
  const _ExerciseSpec({
    required this.id,
    required this.sentence,
    required this.adjective,
    required this.type,
    required this.grammaticalCase,
    required this.gender,
    required this.explanation,
  });

  final String id;
  final String sentence;
  final String adjective;
  final DeclensionType type;
  final GrammaticalCase grammaticalCase;
  final GrammaticalGender gender;
  final String explanation;
}
