import '../language_content_quality.dart';
import '../../core/content_contract.dart';

/// German-owned content quality rules.
final class GermanContentQuality implements LanguageContentQuality {
  const GermanContentQuality();

  @override
  List<String> issues(LearningContent x) {
    final e = <String>[];
    if (x.id.trim().isEmpty) e.add('ID missing');
    if (x.sourceText.trim().isEmpty) e.add('German missing');
    if (x.translationText.trim().isEmpty) e.add('Arabic missing');
    if (x.exampleText.trim().isEmpty) e.add('Example missing');
    if (x.exampleTranslationText.trim().isEmpty)
      e.add('Arabic example missing');
    if (x.skill.isEmpty) e.add('Skill missing');
    if (x.grammaticalMarker.isNotEmpty &&
        !{'der', 'die', 'das'}.contains(x.grammaticalMarker))
      e.add('Invalid Artikel');
    if (x.acceptedForms.any((a) => a.trim().isEmpty))
      e.add('Empty accepted answer');

    final de = x.exampleText.trim();
    if (de.isNotEmpty && !RegExp(r'^[A-ZÄÖÜÉÀÈÂÎÔÛ][^.!?]*[.!?]$').hasMatch(de))
      e.add('German sentence format');
    if (RegExp(r'\b(\p{L}+)\s+\1\b', unicode: true).hasMatch(de.toLowerCase()))
      e.add('Repeated German word');
    final ar = x.exampleTranslationText.trim();
    if (RegExp(r'(.{2,})\s+\1', unicode: true).hasMatch(ar))
      e.add('Repeated Arabic phrase');
    if (RegExp(
      r'\bIch\s+[a-zäöüß]+\s+(ab|an|auf|aus|ein|fest|hoch|mit|nach|vor|weg|weiter|zurück|zu)\s+heute\b',
      caseSensitive: false,
    ).hasMatch(de)) e.add('Likely separable-verb word order');
    if (RegExp(r'\bIch\s+\w+\s+heute\b', caseSensitive: false).hasMatch(de) &&
        de.contains('Ich ')) e.add('Likely generated first-person example');
    if (RegExp(
      r'\b(vermutten|vermutte(?:t|n)?)\b',
      caseSensitive: false,
    ).hasMatch(de + x.sourceText)) e.add('Known verb typo: vermuten');

    final source = x.sourceText.trim();
    if (source.startsWith('die ') ||
        source.startsWith('der ') ||
        source.startsWith('das ')) {
      final parts = source.split(RegExp(r'\s+'));
      if (parts.length > 1 &&
          parts[1].isNotEmpty &&
          parts[1][0] == parts[1][0].toLowerCase())
        e.add('Noun capitalization');
    }
    if (RegExp(r'\b(kundin)\b', caseSensitive: false).hasMatch(de) &&
        de.contains('Die kundin')) e.add('Noun capitalization');
    if (x.translationText.contains('kundin')) e.add('Arabic contamination');
    if (RegExp(
      r'(أنا عادت|نحن عادنا|أنا أرحب الضيف|المستندات يزن|الملابس يزن|البيانات يقيس)',
    ).hasMatch(ar)) e.add('Malformed Arabic example');
    if (RegExp(
      r'\b(übersetze|übersetzt)\s+den\s+Text\s+über\.?$',
      caseSensitive: false,
    ).hasMatch(de)) e.add('Malformed German separable verb example');
    return e;
  }

  @override
  bool isLearnable(LearningContent item) => issues(item).isEmpty;
}
