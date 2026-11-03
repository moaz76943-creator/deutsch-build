enum ValencyType { intransitiveMonadic, transitiveDyadic, ditransitiveTriadic }
class TransitiveIntransitiveVerbValencyMatrix {
  final Map<String, ValencyType> valencyMap = {
    'جلس': ValencyType.intransitiveMonadic,
    'قرأ': ValencyType.transitiveDyadic,
    'أعطى': ValencyType.ditransitiveTriadic,
  };
}
