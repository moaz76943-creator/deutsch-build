enum GermanGender {
  masculine,
  feminine,
  neuter,
  none,
  unknown;

  String get wireName => name;

  static GermanGender fromWire(String? value) {
    final normalized = value?.trim().toLowerCase();
    return GermanGender.values.firstWhere(
      (item) => item.wireName == normalized,
      orElse: () => GermanGender.unknown,
    );
  }
}

enum GermanCase {
  nominative,
  accusative,
  dative,
  genitive;

  String get wireName => name;

  static GermanCase? fromWire(String? value) {
    final normalized = value?.trim().toLowerCase();
    for (final item in GermanCase.values) {
      if (item.wireName == normalized) return item;
    }
    return null;
  }
}

enum GermanNounDeclensionClass {
  strong,
  weak,
  mixed,
  irregular,
  invariant,
  unknown;

  String get wireName => name;

  static GermanNounDeclensionClass fromWire(String? value) {
    final normalized = value?.trim().toLowerCase();
    return GermanNounDeclensionClass.values.firstWhere(
      (item) => item.wireName == normalized,
      orElse: () => GermanNounDeclensionClass.unknown,
    );
  }
}

enum GermanAuxiliary {
  haben,
  sein,
  habenOrSein,
  unknown;

  String get wireName => switch (this) {
        GermanAuxiliary.haben => 'haben',
        GermanAuxiliary.sein => 'sein',
        GermanAuxiliary.habenOrSein => 'haben_or_sein',
        GermanAuxiliary.unknown => 'unknown',
      };

  static GermanAuxiliary fromWire(String? value) =>
      switch (value?.trim().toLowerCase()) {
        'haben' => GermanAuxiliary.haben,
        'sein' => GermanAuxiliary.sein,
        'haben_or_sein' => GermanAuxiliary.habenOrSein,
        _ => GermanAuxiliary.unknown,
      };
}

enum GermanReflexivity {
  none,
  accusative,
  dative,
  contextDependent,
  unknown;

  String get wireName => switch (this) {
        GermanReflexivity.none => 'none',
        GermanReflexivity.accusative => 'accusative',
        GermanReflexivity.dative => 'dative',
        GermanReflexivity.contextDependent => 'context_dependent',
        GermanReflexivity.unknown => 'unknown',
      };

  static GermanReflexivity fromWire(String? value) =>
      switch (value?.trim().toLowerCase()) {
        'none' => GermanReflexivity.none,
        'accusative' => GermanReflexivity.accusative,
        'dative' => GermanReflexivity.dative,
        'context_dependent' => GermanReflexivity.contextDependent,
        _ => GermanReflexivity.unknown,
      };
}
