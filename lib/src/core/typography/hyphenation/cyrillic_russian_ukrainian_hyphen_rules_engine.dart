/// Task 1251: Slavic/Cyrillic hyphenation rules (soft signs ь/ъ)
class CyrillicHyphenEngine {
  bool canBreakAfter(String char) => char != 'ь' && char != 'ъ';
}
