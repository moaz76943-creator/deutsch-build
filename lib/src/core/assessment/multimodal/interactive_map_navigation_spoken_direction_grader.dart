/// Task 1486: Spoken wayfinding/map navigation oral task grader
class MapNavigationGrader {
  int countDirectionalKeywords(String spokenText) => ['links', 'rechts', 'geradeaus', 'an der Ecke'].where((k) => spokenText.contains(k)).length;
}
