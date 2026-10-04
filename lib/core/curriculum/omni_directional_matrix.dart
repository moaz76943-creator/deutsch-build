import 'curriculum_models.dart';

final class LearningLanguageIdentity {
  LearningLanguageIdentity({
    required String id,
    required String englishName,
    required String nativeName,
    required String script,
  })  : id = _languageId(id),
        englishName = _requiredText(englishName, 'englishName'),
        nativeName = _requiredText(nativeName, 'nativeName'),
        script = _requiredText(script, 'script');

  final String id;
  final String englishName;
  final String nativeName;
  final String script;

  @override
  bool operator ==(Object other) =>
      other is LearningLanguageIdentity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

final class DirectedLanguagePair {
  DirectedLanguagePair({
    required this.source,
    required this.target,
  }) {
    if (source.id == target.id) {
      throw ArgumentError(
        'Source and target languages must be different.',
      );
    }
  }

  final LearningLanguageIdentity source;
  final LearningLanguageIdentity target;

  String get id => '${source.id}->${target.id}';

  @override
  bool operator ==(Object other) =>
      other is DirectedLanguagePair &&
      other.source.id == source.id &&
      other.target.id == target.id;

  @override
  int get hashCode => Object.hash(source.id, target.id);
}

final class DirectedCurriculumTask {
  const DirectedCurriculumTask({
    required this.pair,
    required this.task,
  });

  final DirectedLanguagePair pair;
  final CurriculumTask task;

  String get pairTaskId => '${pair.id}::${task.id}';
  String get promptLanguageId => pair.source.id;
  String get responseLanguageId => pair.target.id;
}

final class PairAwareCurriculumPlan {
  PairAwareCurriculumPlan._({
    required this.pair,
    required List<DirectedCurriculumTask> tasks,
  }) : tasks = List<DirectedCurriculumTask>.unmodifiable(tasks);

  factory PairAwareCurriculumPlan.build({
    required DirectedLanguagePair pair,
    required List<CurriculumTask> tasks,
  }) {
    if (tasks.isEmpty) {
      throw ArgumentError('Curriculum task list must not be empty.');
    }
    return PairAwareCurriculumPlan._(
      pair: pair,
      tasks: <DirectedCurriculumTask>[
        for (final task in tasks)
          DirectedCurriculumTask(pair: pair, task: task),
      ],
    );
  }

  final DirectedLanguagePair pair;
  final List<DirectedCurriculumTask> tasks;

  DirectedCurriculumTask taskByCanonicalId(String taskId) {
    for (final item in tasks) {
      if (item.task.id == taskId) return item;
    }
    throw ArgumentError.value(
      taskId,
      'taskId',
      'Unknown curriculum task for pair ${pair.id}.',
    );
  }
}

final class OmniDirectionalLearningMatrix {
  OmniDirectionalLearningMatrix({
    required Iterable<LearningLanguageIdentity> languages,
  }) : languages = List<LearningLanguageIdentity>.unmodifiable(languages) {
    if (this.languages.length < 2) {
      throw ArgumentError('At least two languages are required.');
    }
    final ids = this.languages.map((item) => item.id).toSet();
    if (ids.length != this.languages.length) {
      throw ArgumentError('Language ids must be unique.');
    }
    _byId = <String, LearningLanguageIdentity>{
      for (final language in this.languages) language.id: language,
    };
  }

  factory OmniDirectionalLearningMatrix.standard20() =>
      OmniDirectionalLearningMatrix(languages: projectLanguageRoster20);

  final List<LearningLanguageIdentity> languages;
  late final Map<String, LearningLanguageIdentity> _byId;

  int get directedPairCount =>
      languages.length * (languages.length - 1);

  LearningLanguageIdentity requireLanguage(String rawId) {
    final id = _languageId(rawId);
    final language = _byId[id];
    if (language == null) {
      throw ArgumentError.value(
        rawId,
        'languageId',
        'Unknown project language.',
      );
    }
    return language;
  }

  DirectedLanguagePair requirePair(
    String sourceLanguageId,
    String targetLanguageId,
  ) {
    final source = requireLanguage(sourceLanguageId);
    final target = requireLanguage(targetLanguageId);
    return DirectedLanguagePair(source: source, target: target);
  }

  Iterable<DirectedLanguagePair> pairsFrom(String sourceLanguageId) sync* {
    final source = requireLanguage(sourceLanguageId);
    for (final target in languages) {
      if (target.id == source.id) continue;
      yield DirectedLanguagePair(source: source, target: target);
    }
  }

  Iterable<DirectedLanguagePair> get allPairs sync* {
    for (final source in languages) {
      yield* pairsFrom(source.id);
    }
  }
}

final List<LearningLanguageIdentity> projectLanguageRoster20 =
    List<LearningLanguageIdentity>.unmodifiable(
  <LearningLanguageIdentity>[
    LearningLanguageIdentity(
      id: 'de',
      englishName: 'German',
      nativeName: 'Deutsch',
      script: 'Latn',
    ),
    LearningLanguageIdentity(
      id: 'en',
      englishName: 'English',
      nativeName: 'English',
      script: 'Latn',
    ),
    LearningLanguageIdentity(
      id: 'ar',
      englishName: 'Arabic',
      nativeName: 'العربية',
      script: 'Arab',
    ),
    LearningLanguageIdentity(
      id: 'cmn',
      englishName: 'Mandarin Chinese',
      nativeName: '普通话',
      script: 'Hans',
    ),
    LearningLanguageIdentity(
      id: 'ru',
      englishName: 'Russian',
      nativeName: 'Русский',
      script: 'Cyrl',
    ),
    LearningLanguageIdentity(
      id: 'hi',
      englishName: 'Hindi',
      nativeName: 'हिन्दी',
      script: 'Deva',
    ),
    LearningLanguageIdentity(
      id: 'es',
      englishName: 'Spanish',
      nativeName: 'Español',
      script: 'Latn',
    ),
    LearningLanguageIdentity(
      id: 'fr',
      englishName: 'French',
      nativeName: 'Français',
      script: 'Latn',
    ),
    LearningLanguageIdentity(
      id: 'it',
      englishName: 'Italian',
      nativeName: 'Italiano',
      script: 'Latn',
    ),
    LearningLanguageIdentity(
      id: 'pt',
      englishName: 'Portuguese',
      nativeName: 'Português',
      script: 'Latn',
    ),
    LearningLanguageIdentity(
      id: 'nl',
      englishName: 'Dutch',
      nativeName: 'Nederlands',
      script: 'Latn',
    ),
    LearningLanguageIdentity(
      id: 'tr',
      englishName: 'Turkish',
      nativeName: 'Türkçe',
      script: 'Latn',
    ),
    LearningLanguageIdentity(
      id: 'pl',
      englishName: 'Polish',
      nativeName: 'Polski',
      script: 'Latn',
    ),
    LearningLanguageIdentity(
      id: 'sv',
      englishName: 'Swedish',
      nativeName: 'Svenska',
      script: 'Latn',
    ),
    LearningLanguageIdentity(
      id: 'el',
      englishName: 'Greek',
      nativeName: 'Ελληνικά',
      script: 'Grek',
    ),
    LearningLanguageIdentity(
      id: 'id',
      englishName: 'Indonesian',
      nativeName: 'Bahasa Indonesia',
      script: 'Latn',
    ),
    LearningLanguageIdentity(
      id: 'ja',
      englishName: 'Japanese',
      nativeName: '日本語',
      script: 'Jpan',
    ),
    LearningLanguageIdentity(
      id: 'ko',
      englishName: 'Korean',
      nativeName: '한국어',
      script: 'Kore',
    ),
    LearningLanguageIdentity(
      id: 'fa',
      englishName: 'Persian',
      nativeName: 'فارسی',
      script: 'Arab',
    ),
    LearningLanguageIdentity(
      id: 'ur',
      englishName: 'Urdu',
      nativeName: 'اردو',
      script: 'Arab',
    ),
  ],
);

String _languageId(String raw) {
  final id = raw.trim().toLowerCase();
  if (id.isEmpty ||
      id.length > 16 ||
      !RegExp(r'^[a-z][a-z0-9-]*$').hasMatch(id)) {
    throw ArgumentError.value(
      raw,
      'languageId',
      'Language ids must be lowercase BCP-47-like tokens.',
    );
  }
  return id;
}

String _requiredText(String raw, String field) {
  final value = raw.trim();
  if (value.isEmpty) {
    throw ArgumentError.value(raw, field, 'must not be empty');
  }
  return value;
}
