/// Task 2091: Job interview Q&A scenario matrix (Vorstellungsgespräch)
class JobInterviewScenarioMatrix {
  final List<String> standardQuestions = ['Erzählen Sie etwas über sich', 'Was sind Ihre Stärken?'];
  String getQuestion(int index) => standardQuestions[index % standardQuestions.length];
}
