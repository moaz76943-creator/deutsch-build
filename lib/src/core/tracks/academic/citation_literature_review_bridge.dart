class CitationLiteratureReviewBridge {
  const CitationLiteratureReviewBridge();
  String citePriorWork(String author, int year, String lang) =>
      lang == 'ar' ? 'كما أشار $author ($year)، فإن الدراسات السابقة تؤكد...' : 'As highlighted by $author ($year), prior studies confirm...';
}
