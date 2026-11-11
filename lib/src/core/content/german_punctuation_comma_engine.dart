/// Punctuation rule category under official German orthography (Amtliche Rechtschreibung).
enum CommaRuleCategory {
  mandatorySubordinateClause, // Nebensatz (weil, dass, wenn, ob ...)
  mandatoryInfinitiveUmOhneStatt, // Infinitiv mit um, ohne, statt, anstatt, außer
  mandatoryInfinitiveNounDependence, // Infinitiv hängt von Substantiv ab (Plan, Absicht)
  mandatoryInfinitiveCorrelate, // Infinitiv mit Korrelat (darauf, es)
  mandatoryAdversativeConnector, // aber, sondern, denn
  forbiddenEnglishStyleAdverbComma, // Verbotenes Komma nach Konjunktionaladverb (*Folglich, ...)
}

/// Analysis descriptor of an audited sentence for German punctuation compliance.
class PunctuationAuditReport {
  final String originalSentence;
  final String correctedSentence;
  final bool hasPunctuationError;
  final List<CommaRuleCategory> triggeredRules;
  final String officialRuleCitation;
  final String arabicExplanation;

  PunctuationAuditReport({
    required this.originalSentence,
    required this.correctedSentence,
    required this.hasPunctuationError,
    required this.triggeredRules,
    required this.officialRuleCitation,
    required this.arabicExplanation,
  });

  Map<String, dynamic> toJson() => {
        'original': originalSentence,
        'corrected': correctedSentence,
        'has_error': hasPunctuationError,
        'rules': triggeredRules.map((r) => r.name).toList(),
        'citation': officialRuleCitation,
        'arabic': arabicExplanation,
      };
}

/// Offline rule engine verifying official German comma punctuation rules (Amtliche Kommasetzung).
/// Catches missing mandatory commas in infinitive clauses and flags illegal English-style commas after adverbs.
class GermanPunctuationCommaEngine {
  static const Set<String> _infinitiveSignalConnectors = {
    'um', 'ohne', 'statt', 'anstatt', 'ausser', 'außer'
  };

  /// Audit sentence and verify comma placement.
  static PunctuationAuditReport auditSentencePunctuation(String sentence) {
    final clean = sentence.trim();
    final lower = clean.toLowerCase();
    final rules = <CommaRuleCategory>[];
    String corrected = clean;
    bool hasError = false;
    String citation = '';
    String arabic = '';

    // 1. Check for illegal English-style comma after initial adverb (e.g. "*Folglich, müssen wir...")
    final illegalAdverbCommaRegex = RegExp(r'^(Folglich|Deshalb|Trotzdem|Infolgedessen|Somit|Dennoch),\s+', caseSensitive: false);
    if (illegalAdverbCommaRegex.hasMatch(clean)) {
      hasError = true;
      rules.add(CommaRuleCategory.forbiddenEnglishStyleAdverbComma);
      corrected = clean.replaceFirstMapped(illegalAdverbCommaRegex, (m) => '${m[1]} ');
      citation += 'Duden K 117: Nach Konjunktionaladverbien am Satzanfang steht im Deutschen kein Komma! ';
      arabic += 'خطأ شائع متأثر بالإنجليزية: لا يجوز وضع فاصلة بعد الظرف الرابط في بداية الجملة الألمانية. ';
    }

    // 2. Check for missing comma before "um ... zu", "ohne ... zu", "anstatt ... zu"
    for (final signal in _infinitiveSignalConnectors) {
      final missingCommaRegex = RegExp('\\b([a-zA-ZäöüÄÖÜß]+)\\s+($signal\\s+[a-zA-ZäöüÄÖÜß\\s]+zu\\s+[a-zA-ZäöüÄÖÜß]+)', caseSensitive: false);
      final match = missingCommaRegex.firstMatch(clean);
      if (match != null && !clean.contains(', $signal')) {
        hasError = true;
        rules.add(CommaRuleCategory.mandatoryInfinitiveUmOhneStatt);
        corrected = clean.replaceAll(RegExp('\\b$signal\\b'), ', $signal');
        citation += 'Amtliches Regelwerk § 75 (2): Infinitivgruppen mit um, ohne, statt, anstatt, außer werden obligatorisch durch Komma abgetrennt. ';
        arabic += 'فاصلة إلزامية قبل تركيب المصدر المسبوق بـ (um/ohne/statt). ';
        break;
      }
    }

    // 3. Check for missing comma before "aber" and "sondern"
    final missingAberRegex = RegExp(r'([a-zA-ZäöüÄÖÜß]+)\s+(aber|sondern)\s+([a-zA-ZäöüÄÖÜß]+)', caseSensitive: false);
    if (missingAberRegex.hasMatch(clean) && !clean.contains(', aber') && !clean.contains(', sondern')) {
      hasError = true;
      rules.add(CommaRuleCategory.mandatoryAdversativeConnector);
      corrected = clean.replaceAll(' aber ', ', aber ').replaceAll(' sondern ', ', sondern ');
      citation += 'Amtliches Regelwerk § 74: Entgegensetzende Konjunktionen wie aber, sondern werden durch Komma getrennt. ';
      arabic += 'فاصلة إلزامية قبل أدوات الاستدراك (aber, sondern). ';
    }

    if (!hasError) {
      citation = 'Amtliches Regelwerk: Die Zeichensetzung entspricht den amtlichen Rechtschreibregeln.';
      arabic = 'علامات الترقيم والفواصل مطابقة لقواعد الإملاء الألمانية الرسمية.';
    }

    return PunctuationAuditReport(
      originalSentence: clean,
      correctedSentence: corrected,
      hasPunctuationError: hasError,
      triggeredRules: rules,
      officialRuleCitation: citation.trim(),
      arabicExplanation: arabic.trim(),
    );
  }
}
