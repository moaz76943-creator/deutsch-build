/// Task 1252: French elision (l', d', qu') hyphenation boundary protector
class FrenchElisionGuard {
  bool isElisionPrefix(String prefix) => ['l\'', 'd\'', 'qu\'', 'c\''].contains(prefix.toLowerCase());
}
