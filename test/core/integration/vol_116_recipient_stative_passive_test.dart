import 'package:test/test.dart';
import '../../../lib/src/core/content/german_recipient_stative_passive_engine.dart';
import '../../../lib/src/ui/bridges/vol_116_wave53_ui_bridge.dart';

void main() {
  group('Task 4953: German Recipient & Stative Passive Engine Tests', () {
    late GermanRecipientStativePassiveEngine engine;
    late Vol116Wave53UiBridge uiBridge;

    setUp(() {
      engine = GermanRecipientStativePassiveEngine();
      uiBridge = Vol116Wave53UiBridge(engine: engine);
    });

    tearDown(() {
      uiBridge.dispose();
    });

    test('Engine catalog initializes with rich passive transformation entries', () {
      expect(engine.catalog, isNotEmpty);
      expect(engine.catalog.length, greaterThanOrEqualTo(16));
    });

    test('Recipient passive entries promote Dative to Nominative while retaining Accusative', () {
      final recipientEntries = engine.catalog.where(
        (e) =>
            e.passiveType == PassiveVoiceType.rezipientenpassivErhalten ||
            e.passiveType == PassiveVoiceType.rezipientenpassivBekommen,
      );
      expect(recipientEntries, isNotEmpty);
      for (final item in recipientEntries) {
        expect(item.newNominativeSubject, contains('Nominativ'));
        expect(item.retainedAccusativeObject, contains('Akkusativ'));
      }
    });

    test('Zustandspassiv entries consistently use sein-auxiliary to denote completed states', () {
      final zustandEntries = engine.filterByType(PassiveVoiceType.zustandspassivStative);
      expect(zustandEntries, isNotEmpty);
      for (final item in zustandEntries) {
        expect(
          item.passiveTransformedSentence.contains(' ist ') ||
              item.passiveTransformedSentence.contains(' sind ') ||
              item.passiveTransformedSentence.contains(' war ') ||
              item.passiveTransformedSentence.contains(' waren ') ||
              item.passiveTransformedSentence.contains(' sein'),
          isTrue,
        );
      }
    });

    test('Validator catches erroneous Dative retention in subject position of recipient passive', () {
      final report = engine.validateRecipientPassive(
        auxiliaryUsed: 'bekommen',
        isRecipientInNominative: false,
        isPatientAccusativeRetained: true,
        isRegisterAcceptable: true,
      );

      expect(report.isValid, isFalse);
      expect(report.isRecipientInNominative, isFalse);
      expect(report.issues, anyElement(contains('Kardinalfehler im Rezipientenpassiv')));
    });

    test('Validator catches colloquial kriegen in formal register context', () {
      final report = engine.validateRecipientPassive(
        auxiliaryUsed: 'kriegen',
        isRecipientInNominative: true,
        isPatientAccusativeRetained: true,
        isRegisterAcceptable: false,
      );

      expect(report.isValid, isFalse);
      expect(report.isRegisterCompliant, isFalse);
      expect(report.issues, anyElement(contains('Registerkonflikt')));
    });

    test('Validator approves fully compliant formal recipient passive', () {
      final report = engine.validateRecipientPassive(
        auxiliaryUsed: 'erhalten',
        isRecipientInNominative: true,
        isPatientAccusativeRetained: true,
        isRegisterAcceptable: true,
      );

      expect(report.isValid, isTrue);
      expect(report.issues, isEmpty);
    });

    test('UI Bridge filters and telemetry snapshot function accurately', () {
      final telemetry = uiBridge.getTelemetrySnapshot();
      expect(telemetry['totalPassiveRules'], greaterThanOrEqualTo(16));
      expect(telemetry['legalLiabilityCompliance'], contains('Zero'));

      uiBridge.setTypeFilter(PassiveVoiceType.rezipientenpassivErhalten);
      expect(
        uiBridge.currentFilteredList.every((e) => e.passiveType == PassiveVoiceType.rezipientenpassivErhalten),
        isTrue,
      );

      uiBridge.clearFilters();
      expect(uiBridge.currentFilteredList.length, equals(engine.catalog.length));
    });
  });
}
