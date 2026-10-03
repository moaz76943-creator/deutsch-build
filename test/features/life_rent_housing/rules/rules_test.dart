import 'package:deutsch_bilarabi/features/life_rent_housing/rules/house_rules_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_rent_housing/rules/rent_contract_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_rent_housing/rules/rules_catalog.dart';
import 'package:deutsch_bilarabi/features/life_rent_housing/rules/termination_deposit_sub_agent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('contract phrases cover deposit, cold rent, and warm rent', () {
    const agent = RentContractSubAgent();

    expect(
      agent.entries.map((entry) => entry.id),
      containsAll(<String>[
        'contract-kaution',
        'contract-kaltmiete',
        'contract-warmmiete',
      ]),
    );
    expect(
      agent.entries.any(
        (entry) =>
            entry.german.contains('Kaltmiete') &&
            entry.german.contains('Warmmiete'),
      ),
      isTrue,
    );
  });

  test('house rules phrases keep quiet-time guidance contract specific', () {
    const agent = HouseRulesSubAgent();

    expect(
      agent.entries.map((entry) => entry.id),
      containsAll(<String>[
        'rules-hausordnung',
        'rules-ruhezeiten',
        'rules-common-areas',
      ]),
    );
    expect(
      agent.entries
          .firstWhere((entry) => entry.id == 'rules-ruhezeiten')
          .german,
      contains('Hausordnung'),
    );
  });

  test('termination and deposit phrases request written confirmation', () {
    const agent = TerminationDepositSubAgent();

    expect(
      agent.entries.map((entry) => entry.id),
      containsAll(<String>[
        'termination-notice',
        'termination-confirmation',
        'deposit-accounting',
      ]),
    );
    expect(
      agent.entries.any(
        (entry) => entry.german.contains('schriftlich'),
      ),
      isTrue,
    );
  });

  test('rules catalog aggregates and searches all rule domains', () {
    const catalog = RentHousingRulesCatalog();

    expect(
      catalog.search('Kaution').any(
            (entry) =>
                entry.id == 'contract-kaution' ||
                entry.id == 'deposit-accounting',
          ),
      isTrue,
    );
    expect(
      catalog.search('Ruhezeiten').single.id,
      'rules-ruhezeiten',
    );
    expect(catalog.entries, isNotEmpty);
  });
}
