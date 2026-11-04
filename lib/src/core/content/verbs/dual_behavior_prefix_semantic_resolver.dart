/// Task 2073: Resolves dual-behavior prefixes (über, unter, um, durch) literal vs metaphorical
class DualBehaviorPrefixResolver {
  bool isSeparableLiteral(String verb, String context) => verb.startsWith('um') && context.contains('Straße');
}
