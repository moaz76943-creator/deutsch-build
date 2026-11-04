/// Task 1753: Blacklist validator blocking disallowed or taboo translations
class TerminologyForbiddenTermsBlacklister {
  final Set<String> _blacklist = {};
  bool isForbidden(String term) => _blacklist.contains(term.toLowerCase());
}
