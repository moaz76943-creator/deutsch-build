import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/contracts/universal_scenario_contract.dart';
import 'package:deutsch_bilarabi/core/shell/interaction_mode.dart';
import 'package:deutsch_bilarabi/core/shell/universal_adaptive_shell.dart';
import 'wave_06_scenarios.dart';

class Wave06RunnerScreen extends StatelessWidget {
  const Wave06RunnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scenarios = [
      const _ScenarioRoute(
        title: '1. معايرة الشاهدية واليقين (Evidentiality)',
        contract: Wave06Scenarios.evidentialityScenario,
        mode: InteractionMode.discreteSlider,
      ),
      const _ScenarioRoute(
        title: '2. حقل التلازم اللفظي (Collocations)',
        contract: Wave06Scenarios.collocationScenario,
        mode: InteractionMode.relationalMatrix,
      ),
      const _ScenarioRoute(
        title: '3. كابح التفرع النحوي (Branching Guard)',
        contract: Wave06Scenarios.centerEmbeddingScenario,
        mode: InteractionMode.kineticBlocks,
      ),
      const _ScenarioRoute(
        title: '4. مزلاق التلطيف الدبلوماسي (Face Saving)',
        contract: Wave06Scenarios.faceSavingScenario,
        mode: InteractionMode.discreteSlider,
      ),
      const _ScenarioRoute(
        title: '5. ماسح الحذف والاختزال (Zero Equivalence)',
        contract: Wave06Scenarios.zeroEquivalenceScenario,
        mode: InteractionMode.maskedInspection,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحرك الكوني — الدفعة السادسة'),
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
