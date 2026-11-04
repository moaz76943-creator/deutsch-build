/// Task 1366: Maps passive agents ('von', 'durch') to obl:agent relations
class PassiveAgentMapper {
  String mapAgent(String prep) => prep == 'von' ? 'obl:agent' : 'obl';
}
