import 'package:deutsch_bilarabi/utils/lexical_syntax_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = LexicalSyntaxParser();

  test('gender and usage markers produce styled InlineSpan nodes', () {
    final span = parser.parse('Hund {{m}} {{etym}} {{archaic}} {{slang}}');
    final nodes = span.children!.whereType<TextSpan>().toList();
    expect(span.toPlainText(), 'Hund m. etym. archaic slang');
    expect(nodes[1].style?.fontWeight, FontWeight.w700);
    expect(nodes.last.style?.fontStyle, FontStyle.italic);
  });

  test('renders IPA and lightweight markdown without creating a WebView', () {
    final tick = String.fromCharCode(96);
    final span = parser.parse('Haus [ˈhaʊ̯s] **noun** *German* ' +
        tick + 'das' + tick);
    final nodes = span.children!.whereType<TextSpan>().toList();
    expect(span.toPlainText(), 'Haus [ˈhaʊ̯s] noun German das');
    expect(nodes.any((node) =>
        node.text == '[ˈhaʊ̯s]' && node.style?.color == Colors.teal), true);
    expect(nodes.any((node) =>
        node.text == 'noun' && node.style?.fontWeight == FontWeight.bold), true);
    expect(nodes.any((node) =>
        node.text == 'das' && node.style?.fontFamily == 'monospace'), true);
  });

  test('malformed and unknown lexicographic tokens remain visible', () {
    const source = 'word {{unknown}} {{f <b>text</b> [abc] **unfinished';
    expect(parser.parse(source).toPlainText(), source);
  });

  test('preserves RTL Arabic and never executes HTML', () {
    const source = 'العربية {{f}} <script>bad()</script>';
    final result = parser.parse(source);
    expect(result.toPlainText(), 'العربية f. <script>bad()</script>');
    expect(result.children, isNotEmpty);
  });

  test('supports caller-supplied base typography', () {
    const base = TextStyle(fontSize: 18);
    final span = parser.parse('bonjour {{f}}', style: base);
    expect(span.style, base);
  });
}
