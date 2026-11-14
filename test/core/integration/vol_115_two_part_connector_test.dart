import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_two_part_connector_engine.dart';
import 'package:deutsch_build/src/ui/bridges/vol_115_wave12_ui_bridge.dart';

void main() {
  group('Volume 115 Task 4898 Two-Part Connector Engine Tests', () {
    test('LING-021: sowohl ... als auch builds copulative sentence without comma', () {
      final res = GermanTwoPartConnectorEngine.buildStandardPair(
        subject: 'Er',
        finiteVerb: 'spricht',
        connectorPair: 'sowohl_als_auch',
        elementA: 'Deutsch',
        elementB: 'Arabisch',
      );

      expect(res.type, equals(TwoPartConnectorType.copulative));
      expect(res.fullSentence, equals('Er spricht sowohl Deutsch als auch Arabisch.'));
      expect(res.arabicExplanation, contains('كلا من'));
    });

    test('LING-021: nicht nur ... sondern auch inserts mandatory comma', () {
      final res = GermanTwoPartConnectorEngine.buildStandardPair(
        subject: 'Sie',
        finiteVerb: 'lernt',
        connectorPair: 'nicht_nur_sondern_auch',
        elementA: 'fleißig',
        elementB: 'sehr schnell',
      );

      expect(res.type, equals(TwoPartConnectorType.copulative));
      expect(res.fullSentence, equals('Sie lernt nicht nur fleißig, sondern auch sehr schnell.'));
    });

    test('LING-021: weder ... noch constructs double negative correctly', () {
      final res = GermanTwoPartConnectorEngine.buildStandardPair(
        subject: 'Ich',
        finiteVerb: 'habe',
        connectorPair: 'weder_noch',
        elementA: 'Zeit',
        elementB: 'Geld',
      );

      expect(res.type, equals(TwoPartConnectorType.negative));
      expect(res.fullSentence, equals('Ich habe weder Zeit noch Geld.'));
    });

    test('LING-021: je ... desto enforces comparative verb-final and inversion order', () {
      final res = GermanTwoPartConnectorEngine.buildProportional(
        comparativeA: 'mehr',
        subClauseSubject: 'du',
        subClauseVerb: 'übst',
        comparativeB: 'besser',
        mainClauseVerb: 'wirst',
        mainClauseSubject: 'du',
      );

      expect(res.type, equals(TwoPartConnectorType.proportional));
      expect(res.fullSentence, equals('Je mehr du übst, desto besser wirst du.'));
    });

    test('UI Bridge generates accurate Task 4898 diagnostics report', () {
      final bridge = Vol115Wave12UIBridge();
      final report = bridge.getTask4898Diagnostics();

      expect(report['task_id'], equals(4898));
      expect(report['status'], equals('OPERATIONAL_VERIFIED'));
      expect(report['word_order_enforced'], equals('PARALLEL_AND_PROPORTIONAL_INVERSION'));
    });
  });
}
