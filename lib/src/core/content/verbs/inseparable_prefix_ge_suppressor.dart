/// Task 2072: Inseparable prefix detector suppressing 'ge-' augment in Partizip II
class InseparablePrefixGeSuppressor {
  final Set<String> inseparable = {'be', 'emp', 'ent', 'er', 'ge', 'miss', 'ver', 'zer'};
  bool isInseparable(String prefix) => inseparable.contains(prefix);
}
