# Deutsch بالعربي V116

## هدف الإصدار
دفعة تطوير قوية تركز على سرعة البحث، دقة القرار التعليمي، قابلية الاسترجاع، وجودة محتوى جديد قابل للتدقيق.

## التغييرات
- TextNormalizer treats ä/ö/ü as a/o/u and ß as ss for keyboard-tolerant search.
- SearchIndex adds precomputed exact maps, token index, and O(1) candidate-to-entry lookup.
- Mastery adds time-based retrievability and an actionable nextAction: learn/review/skill/consolidate.
- LearningEngine includes Mastery nextAction in guided-session reasoning.
- Added 20 new bilingual content entries w15915-w15934.
- Preserved all pre-existing IDs and blocked duplicate German entries.
- Version synchronized to pubspec and Android: 1.63.0+73.
- Release gate count updated to 14,678 entries.

## Verification
- pytest: 64 passed
- quality_audit.py: PASS
- security_audit.py: PASS
- compileall: PASS
- Content IDs: 14,678 unique
- German entries: 14,678 unique
- Flutter/Dart SDK: unavailable in this execution environment; APK build not claimed.
- Privacy: publish_to remains none; no public deployment performed.
