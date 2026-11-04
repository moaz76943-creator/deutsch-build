/// Task 1306: Verb argument structure and valency complementation validator
class VerbValencyChecker {
  int getRequiredArguments(String verbType) => verbType == 'ditransitive' ? 3 : (verbType == 'transitive' ? 2 : 1);
}
