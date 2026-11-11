/// Type of determiner preceding the nominalized adjective.
enum DeterminerType { definiteArticle, indefiniteArticle, indefinitePronoun, zeroArticle }

/// Grammatical case.
enum NominalizedCase { nominativ, akkusativ, dativ, genitiv }

/// Person gender or abstract neuter.
enum PersonGender { maskulin, feminin, plural, abstractNeuter }

/// Represents an inflected nominalized adjective structure.
class NominalizedAdjectiveStructure {
  final String baseAdjective;
  final String determiner;
  final String inflectedNounForm;
  final DeterminerType determinerType;
  final NominalizedCase gramCase;
  final PersonGender gender;
  final String fullPhrase;
  final String arabicExplanation;

  NominalizedAdjectiveStructure({
    required this.baseAdjective,
    required this.determiner,
    required this.inflectedNounForm,
    required this.determinerType,
    required this.gramCase,
    required this.gender,
    required this.fullPhrase,
    required this.arabicExplanation,
  });

  Map<String, dynamic> toJson() => {
        'base': baseAdjective,
        'determiner': determiner,
        'noun_form': inflectedNounForm,
        'determiner_type': determinerType.name,
        'case': gramCase.name,
        'gender': gender.name,
        'phrase': fullPhrase,
        'arabic': arabicExplanation,
      };
}

/// Offline rule engine inflecting German nominalized adjectives and participles
/// (Substantivierte Adjektive und Partizipien z.B. der/ein Bekannte(r), etwas Schönes, alles Gute).
/// Enforces adjective ending declension rules while capitalizing as nouns.
class GermanNominalizedAdjectiveEngine {
  /// Inflect nominalized adjective based on determiner, case, and gender.
  static NominalizedAdjectiveStructure inflect({
    required String adjective,
    required DeterminerType determinerType,
    required NominalizedCase gramCase,
    required PersonGender gender,
    String explicitDeterminer = '',
  }) {
    final cleanBase = adjective.trim().toLowerCase();
    final capitalizedStem = cleanBase[0].toUpperCase() + cleanBase.substring(1);

    String suffix = 'e';
    String determiner = explicitDeterminer.trim();
    String arabic = '';

    if (determinerType == DeterminerType.indefinitePronoun) {
      // nach: etwas, nichts, viel, wenig, alles
      final pronoun = explicitDeterminer.isNotEmpty ? explicitDeterminer.trim() : 'etwas';
      determiner = pronoun;

      if (pronoun.toLowerCase() == 'alles') {
        suffix = 'e'; // alles Gute
        arabic = 'اسم مشتق من صفة بعد alles (نهاية e)';
      } else {
        suffix = 'es'; // etwas Schönes, nichts Neues, viel Gutes
        arabic = 'اسم محايد مجرد بعد الضمير غير المحدد (نهاية es)';
      }
    } else if (determinerType == DeterminerType.definiteArticle) {
      // Schwache Deklination (der/die/das)
      if (gramCase == NominalizedCase.nominativ) {
        if (gender == PersonGender.maskulin) {
          determiner = 'der';
          suffix = 'e';
        } else if (gender == PersonGender.feminin) {
          determiner = 'die';
          suffix = 'e';
        } else if (gender == PersonGender.abstractNeuter) {
          determiner = 'das';
          suffix = 'e';
        } else {
          determiner = 'die';
          suffix = 'en';
        }
      } else if (gramCase == NominalizedCase.akkusativ) {
        if (gender == PersonGender.maskulin) {
          determiner = 'den';
          suffix = 'en';
        } else if (gender == PersonGender.feminin) {
          determiner = 'die';
          suffix = 'e';
        } else if (gender == PersonGender.abstractNeuter) {
          determiner = 'das';
          suffix = 'e';
        } else {
          determiner = 'die';
          suffix = 'en';
        }
      } else {
        // Dativ & Genitiv always -en
        determiner = (gender == PersonGender.feminin) ? 'der' : (gender == PersonGender.plural ? 'den' : 'dem');
        suffix = 'en';
      }
      arabic = 'صفة محولة لاسم بعد أداة التعريف (إعراب ضعيف)';
    } else if (determinerType == DeterminerType.indefiniteArticle) {
      // Gemischte Deklination (ein/eine)
      if (gramCase == NominalizedCase.nominativ) {
        if (gender == PersonGender.maskulin) {
          determiner = 'ein';
          suffix = 'er'; // ein Bekannter
        } else if (gender == PersonGender.feminin) {
          determiner = 'eine';
          suffix = 'e';  // eine Bekannte
        } else {
          determiner = 'ein';
          suffix = 'es'; // ein Gutes
        }
      } else if (gramCase == NominalizedCase.akkusativ) {
        if (gender == PersonGender.maskulin) {
          determiner = 'einen';
          suffix = 'en'; // einen Bekannten
        } else if (gender == PersonGender.feminin) {
          determiner = 'eine';
          suffix = 'e';
        } else {
          determiner = 'ein';
          suffix = 'es';
        }
      } else {
        determiner = (gender == PersonGender.feminin) ? 'einer' : 'einem';
        suffix = 'en';
      }
      arabic = 'صفة محولة لاسم بعد أداة التنكير (إعراب مختلط)';
    } else {
      // Zero Article (Starke Deklination)
      if (gender == PersonGender.maskulin) suffix = 'er';
      else if (gender == PersonGender.feminin) suffix = 'e';
      else if (gender == PersonGender.abstractNeuter) suffix = 'es';
      else suffix = 'e';
      determiner = '';
      arabic = 'صفة محولة لاسم بدون أداة (إعراب قوي بنهايات الإشارة)';
    }

    final nounForm = '$capitalizedStem$suffix';
    final phrase = determiner.isNotEmpty ? '$determiner $nounForm' : nounForm;

    return NominalizedAdjectiveStructure(
      baseAdjective: cleanBase,
      determiner: determiner,
      inflectedNounForm: nounForm,
      determinerType: determinerType,
      gramCase: gramCase,
      gender: gender,
      fullPhrase: phrase,
      arabicExplanation: arabic,
    );
  }
}
