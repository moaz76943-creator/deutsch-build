import 'package:deutsch_bilarabi/features/formal_email_builder/application/email_builder_notifier.dart';
import 'package:deutsch_bilarabi/features/formal_email_builder/data/local_email_builder_repository.dart';
import 'package:deutsch_bilarabi/features/formal_email_builder/domain/email_builder_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalEmailBuilderRepository', () {
    test('accepts the canonical five-section formal letter order', () async {
      final repository = LocalEmailBuilderRepository();
      final blocks = await repository.getBlocks(
        scenarioId: 'appointment_b1',
      );

      EmailTemplateBlock bySection(LetterSection section) =>
          blocks.firstWhere((item) => item.section == section);

      final ordered = <EmailTemplateBlock>[
        bySection(LetterSection.salutation),
        bySection(LetterSection.openingHook),
        bySection(LetterSection.mainBodyReason),
        bySection(LetterSection.requestOrComplaint),
        bySection(LetterSection.closingSignoff),
      ];

      expect(await repository.validateStructure(ordered), isTrue);
      expect(
        await repository.validateStructure(ordered.reversed.toList()),
        isFalse,
      );
    });

    test('matches formal scenario blocks to the required register', () async {
      final repository = LocalEmailBuilderRepository();
      final blocks = await repository.getBlocks(
        scenarioId: 'complaint_b2',
      );

      final formalOpening = blocks.firstWhere(
        (item) =>
            item.section == LetterSection.openingHook &&
            item.register == EmailRegister.formalOfficial,
      );
      final friendlyOpening = blocks.firstWhere(
        (item) =>
            item.section == LetterSection.openingHook &&
            item.register == EmailRegister.informalFriendly,
      );

      expect(
        await repository.isRegisterAppropriate(
          scenarioId: 'complaint_b2',
          block: formalOpening,
        ),
        isTrue,
      );
      expect(
        await repository.isRegisterAppropriate(
          scenarioId: 'complaint_b2',
          block: friendlyOpening,
        ),
        isFalse,
      );
    });

    test('formal salutation documents lowercase continuation after comma', () async {
      final repository = LocalEmailBuilderRepository();
      final blocks = await repository.getBlocks(
        scenarioId: 'appointment_b1',
      );
      final salutation = blocks.firstWhere(
        (item) =>
            item.section == LetterSection.salutation &&
            item.register == EmailRegister.formalOfficial,
      );

      expect(salutation.text, 'Sehr geehrte Damen und Herren,');
      expect(salutation.punctuationNoteAr, contains('حرف صغير'));
      expect(salutation.punctuationNoteAr, contains('الفاصلة'));
    });
  });

  group('EmailBuilderNotifier', () {
    test('builds a complete preview in canonical section order', () async {
      final notifier = EmailBuilderNotifier(LocalEmailBuilderRepository());
      addTearDown(notifier.dispose);

      await notifier.load();
      await notifier.selectScenario('appointment_b1');

      for (final section in LetterSection.values) {
        final block = notifier.availableBlocks.firstWhere(
          (item) =>
              item.section == section &&
              item.register == EmailRegister.formalOfficial,
        );
        await notifier.selectSectionBlock(block.id);
      }

      await notifier.validateLetterStructure();

      expect(notifier.isStructureValid, isTrue);
      expect(notifier.registerMismatchSections, isEmpty);
      expect(
        notifier.previewText.indexOf('Sehr geehrte Damen und Herren,'),
        lessThan(notifier.previewText.indexOf('ich schreibe Ihnen')),
      );
      expect(
        notifier.previewText.indexOf('ich schreibe Ihnen'),
        lessThan(notifier.previewText.indexOf('Mit freundlichen Grüßen')),
      );
    });

    test('flags a register mismatch without blocking preview updates', () async {
      final notifier = EmailBuilderNotifier(LocalEmailBuilderRepository());
      addTearDown(notifier.dispose);

      await notifier.load();
      await notifier.selectScenario('complaint_b2');

      final friendlyOpening = notifier.availableBlocks.firstWhere(
        (item) =>
            item.section == LetterSection.openingHook &&
            item.register == EmailRegister.informalFriendly,
      );
      await notifier.selectSectionBlock(friendlyOpening.id);

      expect(
        notifier.selectedBlocks[LetterSection.openingHook]?.id,
        friendlyOpening.id,
      );
      expect(notifier.previewText, contains(friendlyOpening.text));
      expect(
        notifier.registerMismatchSections,
        contains(LetterSection.openingHook),
      );
    });

    test('resetTemplate clears selections while keeping active scenario', () async {
      final notifier = EmailBuilderNotifier(LocalEmailBuilderRepository());
      addTearDown(notifier.dispose);

      await notifier.load();
      await notifier.selectScenario('apology_work_b1');

      final opening = notifier.availableBlocks.firstWhere(
        (item) => item.section == LetterSection.openingHook,
      );
      await notifier.selectSectionBlock(opening.id);

      notifier.resetTemplate();

      expect(notifier.activeScenario?.id, 'apology_work_b1');
      expect(notifier.selectedBlocks, isEmpty);
      expect(notifier.previewText, isEmpty);
      expect(notifier.isStructureValid, isNull);
      expect(notifier.registerMismatchSections, isEmpty);
    });
  });
}
