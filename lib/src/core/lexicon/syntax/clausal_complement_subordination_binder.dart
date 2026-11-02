class ClausalComplementSubordinationBinder {
  String bindThatClause(String mainVerb, String subClause, String lang) =>
      lang == 'ar' ? '$mainVerb أن $subClause' : '$mainVerb dass $subClause';
}
