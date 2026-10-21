import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/features/onboarding/fast_onboarding_screen.dart';
import 'package:deutsch_bilarabi/screens/main_shell_screen.dart';
import 'package:deutsch_bilarabi/screens/onboarding_screen.dart';
import 'package:deutsch_bilarabi/screens/flashcards_screen.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    // The background FFI isolate does not deliver while pumpAndSettle is
    // draining frames. The same factory, without a helper isolate, lets the
    // progress query finish on the test microtask queue.
    databaseFactory = databaseFactoryFfiNoIsolate;
  });

  setUp(() async {
    // Open the progress database before the first frame. pumpAndSettle does not
    // deliver a background SQLite response while the loading spinner is ticking.
    await DatabaseService.instance.progressDb;
  });

  tearDown(() async {
    final db = await DatabaseService.instance.progressDb;
    await db.execute('DELETE FROM srs_progress');
  });

  testWidgets('Fresh install (no progress) routes to OnboardingScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: FastOnboardingScreen())),
    );

    // Wait for async checks to complete and navigation to occur
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(find.byType(OnboardingScreen), findsOneWidget);
    // The previous FastOnboardingScreen route has been replaced/disposed.
    // The CTA must use the current onboarding route, not the stale state.
    await tester.tap(find.text('ابدأ التعلم الآن'));
    await tester.pump();
    expect(find.byType(FlashcardsScreen), findsOneWidget);

  });

  testWidgets('Restored learner (progress exists) routes to MainShellScreen', (WidgetTester tester) async {
    final db = await DatabaseService.instance.progressDb;
    await db.insert('srs_progress', {
      'lexeme_id': 'test1',
      'target_language_code': 'de',
      'repetition_count': 1,
      'interval_days': 1,
      'ease_factor': 2.5,
      'status': 'learning'
    });

    await tester.pumpWidget(const MaterialApp(home: FastOnboardingScreen()));
    // The shell keeps a loading ticker while content is absent, so waiting
    // for a fully idle frame never returns. The route itself is the contract.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(MainShellScreen), findsOneWidget);
  });

  testWidgets('An unresolved progress read is not repeated by rebuilds',
      (WidgetTester tester) async {
    final pending = Completer<int>();
    var readCalls = 0;

    await tester.pumpWidget(MaterialApp(
      home: FastOnboardingScreen(readReviewCount: () {
        readCalls++;
        return pending.future;
      }),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(readCalls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    pending.complete(0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(readCalls, 1);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Disposing during a pending progress read does not navigate',
      (WidgetTester tester) async {
    final pending = Completer<int>();
    await tester.pumpWidget(MaterialApp(
      home: FastOnboardingScreen(readReviewCount: () => pending.future),
    ));
    await tester.pump(const Duration(milliseconds: 10));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Leave the route while the progress read is still awaiting a value.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    pending.complete(0);
    await tester.pump();

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Rapid retry taps do not launch duplicate progress reads',
      (WidgetTester tester) async {
    var reads = 0;
    final retryResult = Completer<int>();

    await tester.pumpWidget(MaterialApp(
      home: FastOnboardingScreen(readReviewCount: () {
        reads++;
        if (reads == 1) {
          return Future<int>.error(const FormatException('corrupted progress'));
        }
        return retryResult.future;
      }),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.text('إعادة المحاولة'), findsOneWidget);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pump();

    expect(reads, 2);
    retryResult.complete(0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(reads, 2);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Invalid local progress recovers through the retry button',
      (WidgetTester tester) async {
    var readCalls = 0;
    await tester.pumpWidget(MaterialApp(
      home: FastOnboardingScreen(readReviewCount: () async {
        readCalls++;
        if (readCalls == 1) {
          throw const FormatException('invalid progress metadata');
        }
        return 0;
      }),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.text('تعذر فتح سجل التقدّم المحلي.'), findsOneWidget);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(readCalls, 2);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

}
