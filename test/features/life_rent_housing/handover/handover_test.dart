import 'package:deutsch_bilarabi/features/life_rent_housing/handover/caretaker_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_rent_housing/handover/defect_notice_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_rent_housing/handover/handover_catalog.dart';
import 'package:deutsch_bilarabi/features/life_rent_housing/handover/handover_protocol_sub_agent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('handover protocol covers condition, keys, and meter readings', () {
    const agent = HandoverProtocolSubAgent();

    expect(
      agent.entries.map((entry) => entry.id),
      containsAll(<String>[
        'handover-protocol-condition',
        'handover-meter-readings',
        'handover-keys',
      ]),
    );
    expect(
      agent.entries.any(
        (entry) =>
            entry.german.contains('Zählerstände') &&
            entry.keywords.contains('Strom'),
      ),
      isTrue,
    );
  });

  test('defect notices cover heating, mould, and water leakage', () {
    const agent = DefectNoticeSubAgent();

    expect(
      agent.entries.map((entry) => entry.id),
      containsAll(<String>[
        'defect-heating',
        'defect-mould',
        'defect-water-leak',
      ]),
    );
    expect(
      agent.entries.every(
        (entry) => entry.german.contains('Bitte'),
      ),
      isTrue,
    );
  });

  test('caretaker phrases support practical maintenance requests', () {
    const agent = CaretakerSubAgent();

    expect(
      agent.entries.map((entry) => entry.id),
      containsAll(<String>[
        'caretaker-appointment',
        'caretaker-access',
        'caretaker-follow-up',
      ]),
    );
  });

  test('handover catalog aggregates and searches without mutating sources', () {
    const catalog = HandoverCatalog();

    final water = catalog.search('Wasser');
    expect(
      water.any((entry) => entry.id == 'defect-water-leak'),
      isTrue,
    );

    final meter = catalog.search('Zählerstand');
    expect(
      meter.any((entry) => entry.id == 'handover-meter-readings'),
      isTrue,
    );

    expect(catalog.entries, isNotEmpty);
  });
}
