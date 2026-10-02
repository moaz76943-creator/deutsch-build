import 'german_grammar_types.dart';

final class VerbValencyFrame {
  const VerbValencyFrame({
    required this.frameId,
    required this.semanticRole,
    this.governedCase,
    this.preposition,
    this.prepositionCase,
    this.objectRequired = true,
  });

  final String frameId;
  final String semanticRole;
  final GermanCase? governedCase;
  final String? preposition;
  final GermanCase? prepositionCase;
  final bool objectRequired;

  bool get hasGovernment =>
      governedCase != null || (preposition != null && prepositionCase != null);
}
