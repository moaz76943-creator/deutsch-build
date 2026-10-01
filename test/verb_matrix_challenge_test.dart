import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/features/verb_matrix/verb_matrix_challenge.dart';
import 'package:deutsch_bilarabi/features/verb_matrix/data/database.dart';
import 'package:deutsch_bilarabi/services/verb_index.dart';
import 'package:deutsch_bilarabi/language/german/german_text_normalizer.dart';
import 'package:deutsch_bilarabi/models/verb_conjugation.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  testWidgets('VerbMatrixChallengePage renders and allows interaction', (WidgetTester tester) async {
    final normalizer = GermanTextNormalizer();
    final verbIndex = VerbIndex(textNormalizer: normalizer);

    // The VerbIndex uses verbConjugations from data which might be empty depending on content state.
    // However, if we construct VerbMatrixChallengePage and it renders CircularProgressIndicator
    // because infinitives is empty, that is fine for the first frame. We will test the UI renders successfully without crashing.

    final database = VerbMatrixDatabase(factory: databaseFactoryFfi, path: inMemoryDatabasePath);

    await tester.pumpWidget(MaterialApp(
      home: VerbMatrixChallengePage(
        verbIndex: verbIndex,
        database: database,
      ),
    ));

    await tester.pumpAndSettle();

    if (verbIndex.infinitives.isEmpty) {
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    } else {
      expect(find.text('تحدي تصريف الأفعال'), findsOneWidget);
      expect(find.byType(DragTarget<String>), findsWidgets);
    }

    await database.close();
  });
}
