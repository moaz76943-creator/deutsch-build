/// Severity level of the stacked genitive chain.
enum GenitiveChainSeverity { acceptableTwoLayers, excessiveThreeOrMore }

/// Decoupling strategy for resolving excessive genitive chaining.
enum DecouplingStrategy { prepositionalVon, verbalRestructuring, compoundFusion }

/// Structure representing an analyzed and decoupled genitive chain.
class GenitiveChainAuditResult {
  final String originalChain;
  final int chainDepth;
  final GenitiveChainSeverity severity;
  final DecouplingStrategy recommendedStrategy;
  final String decoupledAlternative;
  final String stylisticExplanation;
  final String arabicGuidance;

  GenitiveChainAuditResult({
    required this.originalChain,
    required this.chainDepth,
    required this.severity,
    required this.recommendedStrategy,
    required this.decoupledAlternative,
    required this.stylisticExplanation,
    required this.arabicGuidance,
  });

  Map<String, dynamic> toJson() => {
        'original': originalChain,
        'depth': chainDepth,
        'severity': severity.name,
        'strategy': recommendedStrategy.name,
        'decoupled': decoupledAlternative,
        'explanation': stylisticExplanation,
        'arabic': arabicGuidance,
      };
}

/// Offline rule engine detecting and decoupling overly complex German genitive chains (Genitivketten)
/// and nested academic nominal stacking into clear, readable standard German.
class GermanGenitiveChainDecouplerEngine {
  /// Audit a German noun phrase for nested genitive articles (des/der).
  static GenitiveChainAuditResult auditAndDecouple(String phrase) {
    final clean = phrase.trim();
    final tokens = clean.toLowerCase().split(RegExp(r'\s+'));

    // Count occurrences of genitive determiners "des" and "der" acting as attributes
    int genitiveCount = 0;
    for (int i = 1; i < tokens.length; i++) {
      if (tokens[i] == 'des' || tokens[i] == 'der' || tokens[i] == 'eines' || tokens[i] == 'einer') {
        genitiveCount++;
      }
    }

    final isExcessive = genitiveCount >= 2;
    final severity = isExcessive
        ? GenitiveChainSeverity.excessiveThreeOrMore
        : GenitiveChainSeverity.acceptableTwoLayers;

    String alternative = clean;
    DecouplingStrategy strategy = DecouplingStrategy.prepositionalVon;
    String explanation = '';
    String arabic = '';

    if (isExcessive) {
      strategy = DecouplingStrategy.prepositionalVon;
      // Break the second genitive using "von" or compound restructuring
      explanation = 'تراكم إضافات مجرورة متتالية (Genitivkette): يؤدي تتابع أكثر من مضافين مجرورين إلى ثقل لغوي وإرهاق إدراكي في القراءة الأكاديمية.';
      arabic = 'تفكيك توالي الإضافات (سلسلة المضاف إليه) عبر إدخال حرف الجر (von/für) لتخفيف التركيب.';

      // Pattern: die Entwicklung der Kosten des Baus -> die Entwicklung der Kosten für den Bau
      alternative = clean
          .replaceAll('des Baus der Brücke', 'für den Bau der Brücke')
          .replaceAll('des Projekts der Universität', 'für das Projekt der Universität');
      if (alternative == clean) {
        alternative = clean.replaceFirst(' des ', ' von dem ');
      }
    } else {
      explanation = 'سلسلة إضافية مقبولة ضمن حدود الفصاحة الألمانية القياسية (مضاف ومضاف إليه واحد).';
      arabic = 'تركيب إضافي متوازن ولا يحتاج إلى تفكيك.';
    }

    return GenitiveChainAuditResult(
      originalChain: clean,
      chainDepth: genitiveCount + 1,
      severity: severity,
      recommendedStrategy: strategy,
      decoupledAlternative: alternative,
      stylisticExplanation: explanation,
      arabicGuidance: arabic,
    );
  }
}
