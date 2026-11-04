/// Task 2061: German strong verbs vowel-shift (Ablaut) classification engine
class GermanStrongVerbsAblautMatrix {
  final Map<String, String> ablautClasses = {'singen': 'i-a-u', 'sehen': 'e-a-e'};
  String getAblautClass(String verb) => ablautClasses[verb] ?? 'regular';
}
