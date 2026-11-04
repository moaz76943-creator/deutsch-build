/// Task 1755: Multi-domain TM partition routing resolver (tech, law, everyday)
class MultiDomainTmRouter {
  String resolvePartition(String text) => text.contains('function') ? 'TECH' : 'GENERAL';
}
