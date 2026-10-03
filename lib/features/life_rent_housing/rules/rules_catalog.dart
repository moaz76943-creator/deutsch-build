import '../rent_housing_models.dart';
import 'house_rules_sub_agent.dart';
import 'rent_contract_sub_agent.dart';
import 'termination_deposit_sub_agent.dart';

final class RentHousingRulesCatalog {
  const RentHousingRulesCatalog({
    this.contract = const RentContractSubAgent(),
    this.houseRules = const HouseRulesSubAgent(),
    this.termination = const TerminationDepositSubAgent(),
  });

  final RentContractSubAgent contract;
  final HouseRulesSubAgent houseRules;
  final TerminationDepositSubAgent termination;

  List<RentHousingEntry> get entries => List<RentHousingEntry>.unmodifiable(
        <RentHousingEntry>[
          ...contract.entries,
          ...houseRules.entries,
          ...termination.entries,
        ],
      );

  List<RentHousingEntry> search(String query) => List<RentHousingEntry>.unmodifiable(
        entries.where((entry) => entry.matches(query)),
      );
}
