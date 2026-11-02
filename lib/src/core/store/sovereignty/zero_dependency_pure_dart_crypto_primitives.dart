class ZeroDependencyPureDartCryptoPrimitives {
  static List<int> xorCipher(List<int> data, int key) => data.map((b) => b ^ key).toList();
}
