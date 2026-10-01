import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/features/sentence_bridge_puzzle/presentation/sentence_bridge_puzzle.dart';
import 'package:deutsch_bilarabi/features/sentence_bridge_puzzle/domain/models.dart';
import 'package:deutsch_bilarabi/features/sentence_bridge_puzzle/data/database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Mock database to avoid timeout issues during widget testing
class MockSentenceBridgeDatabase extends SentenceBridgeDatabase {
  MockSentenceBridgeDatabase() : super(factory: databaseFactoryFfi, path: inMemoryDatabasePath);

  @override
  Future<List<Map<String, dynamic>>> getRandomPuzzles(int count) async {
    return [
      PuzzleItem(
        id: 'p_test',
        conceptId: 'c_test',
        germanSentence: 'Ich lerne Deutsch',
        arabicSentence: 'أنا أتعلم الألمانية',
      ).toMap()
    ];
  }

  @override
  Future<void> recordAttempt(Map<String, dynamic> attempt) async {
    // No-op for test
  }
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  Widget buildTestableWidget(SentenceBridgeDatabase db) {
    return MaterialApp(
      home: Scaffold(
        body: SentenceBridgePuzzleWidget(database: db),
      ),
    );
  }

  testWidgets('Renders puzzle, correctly assembles sentence, and verifies result', (WidgetTester tester) async {
    final db = MockSentenceBridgeDatabase();
    await tester.pumpWidget(buildTestableWidget(db));

    // Wait for async load to finish
    await tester.pumpAndSettle();

    // Verify hint exists
    expect(find.text('أنا أتعلم الألمانية'), findsOneWidget);

    // Verify scrambled words exist
    expect(find.text('Ich'), findsOneWidget);
    expect(find.text('lerne'), findsOneWidget);
    expect(find.text('Deutsch'), findsOneWidget);

    // Tap words to assemble
    await tester.tap(find.text('Ich'));
    await tester.pump();
    await tester.tap(find.text('lerne'));
    await tester.pump();
    await tester.tap(find.text('Deutsch'));
    await tester.pump();

    // Check Answer
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();

    // Verify success message
    expect(find.text('Correct!'), findsOneWidget);
  });
}
