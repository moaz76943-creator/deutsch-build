import 'package:flutter/material.dart';
import '../../core/contracts/universal_scenario_contract.dart';
import '../../core/shell/interaction_mode.dart';
import '../../core/shell/universal_adaptive_shell.dart';
import 'wave_07_scenarios.dart';

class Wave07RunnerScreen extends StatelessWidget {
  const Wave07RunnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scenarios = [
      _ScenarioRoute(
        title: '1. ناظم التزامن الإيقاعي (Metrical Isochrony)',
        contract: Wave07Scenarios.rhythmScenario,
        mode: InteractionMode.kineticBlocks,
      ),
      _ScenarioRoute(
        title: '2. مقياس المسافة الاجتماعية وصيغ الخطاب (Honorifics)',
        contract: Wave07Scenarios.honorificScenario,
        mode: InteractionMode.discreteSlider,
      ),
      _ScenarioRoute(
        title: '3. شبكة الترابط الإحالي النصي (Anaphora Mesh)',
        contract: Wave07Scenarios.anaphoraScenario,
        mode: InteractionMode.relationalMatrix,
      ),
      _ScenarioRoute(
        title: '4. مستشعر الاستلزام الحواري والتضمين (Implicature)',
        contract: Wave07Scenarios.implicatureScenario,
        mode: InteractionMode.maskedInspection,
      ),
      _ScenarioRoute(
        title: '5. مخزن حشوات التردد وتدارك الكلام (Hesitation Buffer)',
        contract: Wave07Scenarios.hesitationScenario,
        mode: InteractionMode.discreteSlider,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحرك الكوني — الدفعة السابعة'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: scenarios.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = scenarios[index];
          return Card(
            elevation: 1.5,
            child: ListTile(
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('المعرف: ${item.contract.scenarioId} | النمط: ${item.mode.name}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UniversalAdaptiveShell(
                      contract: item.contract,
                      mode: item.mode,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ScenarioRoute {
  final String title;
  final UniversalScenarioContract contract;
  final InteractionMode mode;

  const _ScenarioRoute({
    required this.title,
    required this.contract,
    required this.mode,
  });
}
