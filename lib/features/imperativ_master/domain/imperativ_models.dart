enum ImperativTarget { duForm, ihrForm, sieForm, wirForm }

enum ImperativVowelChange {
  none,
  eToI,
  eToIe,
  umlautDropped,
  irregularSein,
}

extension ImperativTargetLabels on ImperativTarget {
  String get pronoun => switch (this) {
        ImperativTarget.duForm => 'du',
        ImperativTarget.ihrForm => 'ihr',
        ImperativTarget.sieForm => 'Sie',
        ImperativTarget.wirForm => 'wir',
      };

  String get labelAr => switch (this) {
        ImperativTarget.duForm => 'أنت · du',
        ImperativTarget.ihrForm => 'أنتم · ihr',
        ImperativTarget.sieForm => 'حضرتك / حضراتكم · Sie',
        ImperativTarget.wirForm => 'لنقم معاً · wir',
      };
}

extension ImperativVowelChangeLabels on ImperativVowelChange {
  String get labelAr => switch (this) {
        ImperativVowelChange.none => 'بناء قياسي لصيغة الأمر',
        ImperativVowelChange.eToI => 'يتحوّل e إلى i',
        ImperativVowelChange.eToIe => 'يتحوّل e إلى ie',
        ImperativVowelChange.umlautDropped => 'يُحذف الـ Umlaut في صيغة du',
        ImperativVowelChange.irregularSein => 'فعل sein له صيغة أمر استثنائية',
      };
}

final class ImperativDrillItem {
  const ImperativDrillItem({
    required this.id,
    required this.infinitive,
    required this.target,
    required this.correctForm,
    required this.vowelChange,
    required this.referenceForm,
    required this.contextSentence,
    required this.explanationAr,
    this.acceptedForms = const <String>[],
  });

  final String id;
  final String infinitive;
  final ImperativTarget target;
  final String correctForm;
  final ImperativVowelChange vowelChange;
  final String referenceForm;
  final String contextSentence;
  final String explanationAr;
  final List<String> acceptedForms;
}
