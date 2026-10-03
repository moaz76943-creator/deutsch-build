import 'package:deutsch_bilarabi/features/life_furniture_home_setup/assembly/assembly_defects_hub.dart';
import 'package:deutsch_bilarabi/features/life_furniture_home_setup/assembly/assembly_models.dart';
import 'package:deutsch_bilarabi/features/life_furniture_home_setup/assembly/assembly_service_agent.dart';
import 'package:deutsch_bilarabi/features/life_furniture_home_setup/assembly/defects_reklamation_agent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('assembly agent covers instructions, tools, and montage service', () {
    const agent = AssemblyServiceAgent();

    expect(agent.scenarios.any((x) => x.id == 'assembly-instructions'), isTrue);
    expect(agent.scenarios.any((x) => x.id == 'assembly-tools'), isTrue);
    expect(agent.scenarios.any((x) => x.id == 'montage-service'), isTrue);
  });

  test('defect agent covers missing and damaged parts', () {
    const agent = DefectsReklamationAgent();

    expect(agent.scenarios.any((x) => x.issue == AssemblyIssue.missingPart), isTrue);
    expect(agent.scenarios.any((x) => x.issue == AssemblyIssue.wrongScrew), isTrue);
    expect(agent.scenarios.any((x) => x.issue == AssemblyIssue.transportDamage), isTrue);
  });

  test('hub narrows complaints by issue and search query', () {
    final hub = AssemblyDefectsHubController();
    hub
      ..setIssue(AssemblyIssue.transportDamage)
      ..setQuery('verkratzt');

    expect(hub.visibleScenarios, hasLength(1));
    expect(hub.visibleScenarios.single.id, 'replace-scratched-part');
    hub.dispose();
  });
}
