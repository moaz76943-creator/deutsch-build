import 'package:deutsch_bilarabi/ui_v35/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('rtlAppBuilder keeps pushed routes in RTL', (tester) async {
    const homeKey = Key('rtl-home');
    const routeKey = Key('rtl-route');

    await tester.pumpWidget(
      MaterialApp(
        builder: rtlAppBuilder,
        home: Builder(
          key: homeKey,
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(
                    body: SizedBox(key: routeKey),
                  ),
                ),
              ),
              child: const Text('افتح الصفحة'),
            ),
          ),
        ),
      ),
    );

    expect(
      Directionality.of(tester.element(find.byKey(homeKey))),
      TextDirection.rtl,
    );

    await tester.tap(find.text('افتح الصفحة'));
    await tester.pumpAndSettle();

    expect(
      Directionality.of(tester.element(find.byKey(routeKey))),
      TextDirection.rtl,
    );
  });

  testWidgets('German text can still opt into LTR locally', (tester) async {
    const germanKey = Key('german-ltr');

    await tester.pumpWidget(
      MaterialApp(
        builder: rtlAppBuilder,
        home: const Scaffold(
          body: Text(
            'Wie geht es dir?',
            key: germanKey,
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.byKey(germanKey));
    expect(text.textDirection, TextDirection.ltr);
    expect(
      Directionality.of(tester.element(find.byKey(germanKey))),
      TextDirection.rtl,
    );
  });
}
