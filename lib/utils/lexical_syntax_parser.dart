import 'package:flutter/material.dart';

/// Lightweight, bounded lexicographic markup parser.
///
/// Produces paint-ready InlineSpan nodes without HTML, WebView or plugins.
/// Unknown and malformed syntax is kept as literal text.
/// Supports gender/register tags, IPA, bold, italic and inline code.
class LexicalSyntaxParser {
  static const Map<String, String> _tags = <String, String>{
    'm': 'm.',
    'f': 'f.',
    'n': 'n.',
    'etym': 'etym.',
    'archaic': 'archaic',
    'slang': 'slang',
    'colloquial': 'colloquial',
    'formal': 'formal',
    'pl': 'plural',
  };

  static const TextStyle _genderStyle = TextStyle(
    color: Colors.indigo,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle _registerStyle = TextStyle(
    color: Colors.deepOrange,
    fontStyle: FontStyle.italic,
  );
  static const TextStyle _ipaStyle = TextStyle(
    color: Colors.teal,
    fontStyle: FontStyle.italic,
  );
  static const TextStyle _codeStyle = TextStyle(fontFamily: 'monospace');
  static const TextStyle _boldStyle = TextStyle(fontWeight: FontWeight.bold);
  static const TextStyle _italicStyle = TextStyle(fontStyle: FontStyle.italic);
  static final RegExp _ipaSignals = RegExp(
    r'[ˈˌːəɐɑɒæɓβçðɖɛɜɞɟɡɣɥɦɪɨʝɭɬɮʎɯɰŋɳɲɔøœɹɾʁɻʃʂθʊʋʌʍχʏʑʒʔʕʰʲʷ̩̃͡]',
  );

  const LexicalSyntaxParser();

  TextSpan parse(String source, {TextStyle? style}) {
    final children = <InlineSpan>[];
    final plain = StringBuffer();

    void flushText() {
      if (plain.isNotEmpty) {
        children.add(TextSpan(text: plain.toString()));
        plain.clear();
      }
    }

    var i = 0;
    while (i < source.length) {
      if (source.startsWith('{{', i)) {
        final close = source.indexOf('}}', i + 2);
        if (close >= 0 && close - i <= 24) {
          final code = source.substring(i + 2, close).trim().toLowerCase();
          final label = _tags[code];
          if (label != null) {
            flushText();
            children.add(TextSpan(
              text: label,
              style: code == 'm' || code == 'f' || code == 'n'
                  ? _genderStyle
                  : _registerStyle,
            ));
            i = close + 2;
            continue;
          }
        }
      }

      if (source[i] == '[') {
        final close = source.indexOf(']', i + 1);
        if (close > i + 1 && close - i <= 80) {
          final inner = source.substring(i + 1, close);
          if (_ipaSignals.hasMatch(inner) ||
              (inner.startsWith('/') && inner.endsWith('/'))) {
            flushText();
            children.add(TextSpan(
              text: source.substring(i, close + 1),
              style: _ipaStyle,
            ));
            i = close + 1;
            continue;
          }
        }
      }

      if (source.startsWith('**', i)) {
        final close = source.indexOf('**', i + 2);
        if (close > i + 2) {
          flushText();
          children.add(TextSpan(
            text: source.substring(i + 2, close),
            style: _boldStyle,
          ));
          i = close + 2;
          continue;
        }
      }
      if (source[i] == '*' || source[i] == '_') {
        final marker = source[i];
        final close = source.indexOf(marker, i + 1);
        if (close > i + 1) {
          flushText();
          children.add(TextSpan(
            text: source.substring(i + 1, close),
            style: _italicStyle,
          ));
          i = close + 1;
          continue;
        }
      }
      final tick = String.fromCharCode(96);
      if (source[i] == tick) {
        final close = source.indexOf(tick, i + 1);
        if (close > i + 1) {
          flushText();
          children.add(TextSpan(
            text: source.substring(i + 1, close),
            style: _codeStyle,
          ));
          i = close + 1;
          continue;
        }
      }
      plain.write(source[i]);
      i++;
    }
    flushText();
    return TextSpan(style: style, children: children);
  }
}
