/// Task 1307: German Satzklammer separable prefix verbal bracket constructor
class SeparablePrefixConstructor {
  Map<String, String> splitPrefix(String verb) => verb.startsWith('auf') ? {'base': verb.substring(3), 'prefix': 'auf'} : {'base': verb, 'prefix': ''};
}
