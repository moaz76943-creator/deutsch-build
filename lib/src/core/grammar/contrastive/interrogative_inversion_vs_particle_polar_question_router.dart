/// Task 1387: Polar question formation (German inversion vs Arabic 'هل')
class PolarQuestionRouter {
  String formQuestion(String lang, String statement) => lang == 'de' ? 'Verb_First' : 'Hal_Prefix';
}
