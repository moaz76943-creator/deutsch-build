enum ProductionMode { recognize, guided, free }

class ProductionTask {
  final String itemId;
  final ProductionMode mode;
  final String prompt;
  final String expected;
  final List<String> accepted;
  final String hint;
  const ProductionTask({
    required this.itemId,
    required this.mode,
    required this.prompt,
    required this.expected,
    this.accepted = const [],
    this.hint = '',
  });
}
