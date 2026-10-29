enum GovernedCase { accusative, dative }

class VerbValencyRecord {
  final String verb;
  final String preposition;
  final GovernedCase requiredCase;
  final bool isReflexive;
  final String arabicMeaning;
  final String exampleSentence;

  const VerbValencyRecord({
    required this.verb,
    required this.preposition,
    required this.requiredCase,
    this.isReflexive = false,
    required this.arabicMeaning,
    required this.exampleSentence,
  });
}

class ValencyValidationResult {
  final bool isValid;
  final String? errorMessage;
  final VerbValencyRecord? expectedRecord;

  const ValencyValidationResult({
    required this.isValid,
    this.errorMessage,
    this.expectedRecord,
  });
}

/// Offline linguistic engine mapping and auditing German verb-preposition valency pairs.
class PrepositionalValencyEngine {
  static const List<VerbValencyRecord> _valencyCatalog = [
    VerbValencyRecord(
      verb: 'warten',
      preposition: 'auf',
      requiredCase: GovernedCase.accusative,
      arabicMeaning: 'ينتظر',
      exampleSentence: 'Ich warte auf den Bus.',
    ),
    VerbValencyRecord(
      verb: 'denken',
      preposition: 'an',
      requiredCase: GovernedCase.accusative,
      arabicMeaning: 'يفكر في',
      exampleSentence: 'Ich denke an die Prüfung.',
    ),
    VerbValencyRecord(
      verb: 'teilnehmen',
      preposition: 'an',
      requiredCase: GovernedCase.dative,
      arabicMeaning: 'يشارك في',
      exampleSentence: 'Wir nehmen an dem Kurs teil.',
    ),
    VerbValencyRecord(
      verb: 'gehören',
      preposition: 'zu',
      requiredCase: GovernedCase.dative,
      arabicMeaning: 'ينتمي إلى / من ضمن',
      exampleSentence: 'Das gehört zu meinen Aufgaben.',
    ),
    VerbValencyRecord(
      verb: 'freuen',
      preposition: 'auf',
      requiredCase: GovernedCase.accusative,
      isReflexive: true,
      arabicMeaning: 'يتطلع بفرح وشوق إلى أمر مستقبلي',
      exampleSentence: 'Ich freue mich auf den Urlaub.',
    ),
    VerbValencyRecord(
      verb: 'freuen',
      preposition: 'über',
      requiredCase: GovernedCase.accusative,
      isReflexive: true,
      arabicMeaning: 'يفرح ويسر بأمر واقع حالياً أو ماضياً',
      exampleSentence: 'Ich freue mich über das Geschenk.',
    ),
    VerbValencyRecord(
      verb: 'abhängen',
      preposition: 'von',
      requiredCase: GovernedCase.dative,
      arabicMeaning: 'يعتمد على / يرتبط بـ',
      exampleSentence: 'Das hängt vom Wetter ab.',
    ),
    VerbValencyRecord(
      verb: 'bestehen',
      preposition: 'aus',
      requiredCase: GovernedCase.dative,
      arabicMeaning: 'يتكون / يتألف من',
      exampleSentence: 'Das Buch besteht aus fünf Kapiteln.',
    ),
    VerbValencyRecord(
      verb: 'bestehen',
      preposition: 'auf',
      requiredCase: GovernedCase.dative,
      arabicMeaning: 'يُصر ويتمسك بـ',
      exampleSentence: 'Er besteht auf seinem Recht.',
    ),
  ];

  /// التحقق الصارم من صحة حرف الجر والحالة الإعرابية المستخدمة مع الفعل
  ValencyValidationResult auditUsage({
    required String verb,
    required String usedPreposition,
    required GovernedCase usedCase,
  }) {
    final vLower = verb.toLowerCase().trim();
    final pLower = usedPreposition.toLowerCase().trim();

    final matches = _valencyCatalog.where((r) => r.verb.toLowerCase() == vLower).toList();
    if (matches.isEmpty) {
      return const ValencyValidationResult(isValid: true); // الفعل غير مقيد في الكتالوج
    }

    final exactMatch = matches.firstWhere(
      (r) => r.preposition.toLowerCase() == pLower && r.requiredCase == usedCase,
      orElse: () => matches.first,
    );

    if (exactMatch.preposition.toLowerCase() != pLower) {
      return ValencyValidationResult(
        isValid: false,
        errorMessage: 'خطأ في حرف الجر: الفعل "$verb" يأخذ حرف الجر "${exactMatch.preposition}" وليس "$usedPreposition".',
        expectedRecord: exactMatch,
      );
    }

    if (exactMatch.requiredCase != usedCase) {
      return ValencyValidationResult(
        isValid: false,
        errorMessage: 'خطأ إعرابي: حرف الجر "${exactMatch.preposition}" مع الفعل "$verb" يفرض حالة ${exactMatch.requiredCase.name} وليس ${usedCase.name}.',
        expectedRecord: exactMatch,
      );
    }

    return ValencyValidationResult(isValid: true, expectedRecord: exactMatch);
  }
}
