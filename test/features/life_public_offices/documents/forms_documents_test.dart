import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_public_offices/documents/documents_models.dart';
import 'package:deutsch_bilarabi/features/life_public_offices/documents/documents_screen.dart';
import 'package:deutsch_bilarabi/features/life_public_offices/documents/forms_documents_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormsDocumentsAgent', () {
    test('covers forms, identity, certification, power of attorney and Nachreichen', () {
      final agent = FormsDocumentsAgent();
      final topics = agent.allPhrases.map((item) => item.topic).toSet();

      expect(topics, contains(DocumentsTopic.formFilling));
      expect(topics, contains(DocumentsTopic.identityProof));
      expect(topics, contains(DocumentsTopic.certification));
      expect(topics, contains(DocumentsTopic.powerOfAttorney));
      expect(topics, contains(DocumentsTopic.missingDocuments));
    });

    test('filters by document topic', () {
      final agent = FormsDocumentsAgent();

      agent.setTopic(DocumentsTopic.missingDocuments);

      expect(agent.visiblePhrases, isNotEmpty);
      expect(
        agent.visiblePhrases.every(
          (item) => item.topic == DocumentsTopic.missingDocuments,
        ),
        isTrue,
      );
    });

    test('searches German and Arabic document terms', () {
      final agent = FormsDocumentsAgent();

      agent.setQuery('Beglaubigung');
      expect(
        agent.visiblePhrases.any(
          (item) => item.topic == DocumentsTopic.certification,
        ),
        isTrue,
      );

      agent.setQuery('وكالة');
      expect(
        agent.visiblePhrases.any(
          (item) => item.topic == DocumentsTopic.powerOfAttorney,
        ),
        isTrue,
      );
    });
  });

  testWidgets('documents hub renders safe glass UI', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FormsDocumentsHub()),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Formulare & Dokumente'), findsOneWidget);
    expect(find.byKey(const ValueKey('documents-search')), findsOneWidget);
  });
}
