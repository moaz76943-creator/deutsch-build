/// Declarative specification of a language's structural and grammatical topology.
class LanguageProfile {
  final String isoCode; // e.g. "de", "ar", "en", "tr", "ja"
  final String autonym; // Native name: "Deutsch", "العربية", "English"
  final String englishName;
  final String scriptDirection; // "ltr" or "rtl"
  final String scriptFamily; // "Latin", "Arabic", "Cyrillic", "CJK", etc.
  final String typology; // "SVO", "SOV", "VSO"
  final String morphologyType; // "Fusional", "Agglutinative", "Isolating"
  final int casesCount; // e.g. 4 (de), 3 (ar), 0 (en), 6 (ru)
  final List<String> caseNames;
  final List<String> genders; // ["m", "f", "n"] or ["none"]
  final bool hasArticles;
  final bool hasNounDeclension;
  final bool hasVerbConjugation;
  final bool hasDualNumber; // Arabic Muthanna

  const LanguageProfile({
    required this.isoCode,
    required this.autonym,
    required this.englishName,
    required this.scriptDirection,
    required this.scriptFamily,
    required this.typology,
    required this.morphologyType,
    required this.casesCount,
    required this.caseNames,
    required this.genders,
    required this.hasArticles,
    required this.hasNounDeclension,
    required this.hasVerbConjugation,
    this.hasDualNumber = false,
  });

  bool get isRtl => scriptDirection.toLowerCase() == 'rtl';

  factory LanguageProfile.fromJson(Map<String, dynamic> json) {
    return LanguageProfile(
      isoCode: json['isoCode'] as String,
      autonym: json['autonym'] as String,
      englishName: json['englishName'] as String,
      scriptDirection: json['scriptDirection'] as String,
      scriptFamily: json['scriptFamily'] as String,
      typology: json['typology'] as String,
      morphologyType: json['morphologyType'] as String,
      casesCount: json['casesCount'] as int,
      caseNames: List<String>.from(json['caseNames'] as List),
      genders: List<String>.from(json['genders'] as List),
      hasArticles: json['hasArticles'] as bool,
      hasNounDeclension: json['hasNounDeclension'] as bool,
      hasVerbConjugation: json['hasVerbConjugation'] as bool,
      hasDualNumber: json['hasDualNumber'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'isoCode': isoCode,
    'autonym': autonym,
    'englishName': englishName,
    'scriptDirection': scriptDirection,
    'scriptFamily': scriptFamily,
    'typology': typology,
    'morphologyType': morphologyType,
    'casesCount': casesCount,
    'caseNames': caseNames,
    'genders': genders,
    'hasArticles': hasArticles,
    'hasNounDeclension': hasNounDeclension,
    'hasVerbConjugation': hasVerbConjugation,
    'hasDualNumber': hasDualNumber,
  };
}
