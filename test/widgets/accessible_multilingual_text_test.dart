import 'dart:ui' show LocaleStringAttribute, TextRange;

import 'package:deutsch_bilarabi/widgets/accessible_multilingual_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exposes exactly one localized semantic label for German', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: AccessibleMultilingualText(
        text: 'Haus', languageTag: 'de-DE',
      )),
    ));
    final wrapper = tester.widget<Semantics>(find.descendant(
      of: find.byType(AccessibleMultilingualText),
      matching: find.byType(Semantics),
    ));
    final label = wrapper.properties.attributedLabel!;
    expect(label.string, 'Haus');
    expect(label.attributes, hasLength(1));
    final locale = label.attributes.single as LocaleStringAttribute;
    expect(locale.locale.toLanguageTag(), 'de-DE');
    expect(locale.range, const TextRange(start: 0, end: 4));
    expect(wrapper.properties.value, isNull,
      reason: 'Repeating the label in value makes TalkBack speak it twice');
    final text = tester.widget<Text>(find.byType(Text).last);
    expect((text.textSpan! as TextSpan).locale!.toLanguageTag(), 'de-DE');
  });

  testWidgets('sets RTL direction without changing the host app locale', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: AccessibleMultilingualText(
        text: 'سلام', languageTag: 'ar-JO',
      )),
    ));
    final wrapper = tester.widget<Semantics>(find.descendant(
      of: find.byType(AccessibleMultilingualText),
      matching: find.byType(Semantics),
    ));
    expect(wrapper.properties.textDirection, TextDirection.rtl);
    expect(wrapper.properties.attributedLabel!.attributes.single,
      isA<LocaleStringAttribute>());
    final text = tester.widget<Text>(find.byType(Text).last);
    expect(text.textDirection, TextDirection.rtl);
  });

  testWidgets('hides empty strings and degrades safely for unsupported tags', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Column(children: [
        AccessibleMultilingualText(text: ' ', languageTag: 'de'),
        AccessibleMultilingualText(text: 'abc', languageTag: '!bad!'),
      ])),
    ));
    expect(find.byType(SizedBox), findsWidgets);
    final items = find.byType(AccessibleMultilingualText);
    final visible = find.descendant(of: items.last, matching: find.byType(Semantics));
    final wrapper = tester.widget<Semantics>(visible);
    expect(wrapper.properties.attributedLabel!.string, 'abc');
    expect(wrapper.properties.attributedLabel!.attributes, isEmpty);
  });

  test('parses language-script-region tags without losing script', () {
    final locale = AccessibleMultilingualText.parseLanguageTag('zh-Hant-TW')!;
    expect(locale.languageCode, 'zh');
    expect(locale.scriptCode, 'Hant');
    expect(locale.countryCode, 'TW');
    expect(AccessibleMultilingualText.parseLanguageTag(''), isNull);
    expect(AccessibleMultilingualText.parseLanguageTag('en-x-private'), isNull);
  });
}
