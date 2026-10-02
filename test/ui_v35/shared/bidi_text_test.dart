import 'package:deutsch_bilarabi/core/language/app_text_direction.dart';
import 'package:deutsch_bilarabi/core/text/bidi_boundary.dart';
import 'package:deutsch_bilarabi/core/text/directional_text.dart';
import 'package:deutsch_bilarabi/ui_v35/shared/text/bidi_text.dart';
import 'package:deutsch_bilarabi/ui_v35/shared/text/bilingual_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BidiText forces German LTR and Arabic RTL', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            BidiText(
              DirectionalText.german('Deutsch'),
              key: const Key('de'),
            ),
            BidiText(
              DirectionalText.arabic('العربية'),
              key: const Key('ar'),
            ),
          ],
        ),
      ),
    );

    final german = tester.widget<Text>(find.byKey(const Key('de')));
    final arabic = tester.widget<Text>(find.byKey(const Key('ar')));
    expect(german.textDirection, TextDirection.ltr);
    expect(arabic.textDirection, TextDirection.rtl);
  });

  testWidgets('BilingualText isolates mixed spans instead of raw concatenation',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BilingualText(
          baseDirection: AppTextDirection.rtl,
          segments: <DirectionalText>[
            DirectionalText.arabic('استخدم '),
            DirectionalText.german('mit dem Bus'),
            DirectionalText.arabic(' هنا'),
          ],
        ),
      ),
    );

    final rich = tester.widget<Text>(find.byType(Text));
    final plain = rich.textSpan!.toPlainText();
    expect(plain, contains(BidiBoundary.rli));
    expect(plain, contains(BidiBoundary.lri));
    expect(rich.textDirection, TextDirection.rtl);
  });
}
