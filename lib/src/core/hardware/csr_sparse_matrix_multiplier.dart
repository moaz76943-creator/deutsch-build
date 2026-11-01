class CsrSparseMatrixMultiplier {
  final List<double> values;
  final List<int> colIndices;
  final List<int> rowPointers;
  const CsrSparseMatrixMultiplier({required this.values, required this.colIndices, required this.rowPointers});
}
