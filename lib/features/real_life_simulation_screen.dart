import 'package:flutter/material.dart';
import '../ui/app_design_system.dart';
import '../ui/app_directional_text.dart';

class SimulationScenario {
  final String title;
  final String category;
  final IconData icon;
  final List<String> phrases;

  const SimulationScenario({
    required this.title,
    required this.category,
    required this.icon,
    required this.phrases,
  });
}

class RealLifeSimulationScreen extends StatelessWidget {
  const RealLifeSimulationScreen({super.key});

  final List<SimulationScenario> _scenarios = const [
    SimulationScenario(
      title: 'في عيادة الطبيب (Beim Arzt)',
      category: 'صحة ورعاية',
      icon: Icons.local_hospital_rounded,
      phrases: [
        'Ich habe starke Schmerzen im Bauch.',
        'Können Sie mir bitte eine Arbeitsunfähigkeitsbescheinigung geben?',
        'Wie oft am Tag soll ich die Tabletten nehmen?',
      ],
    ),
    SimulationScenario(
      title: 'في البلدية وتسجيل السكن (Bürgeramt)',
      category: 'معاملات رسمية',
      icon: Icons.account_balance_rounded,
      phrases: [
        'Ich möchte meine neue Wohnung anmelden.',
        'Hier ist meine Wohnungsgeberbestätigung.',
        'Ich brauche eine Meldebescheinigung.',
      ],
    ),
    SimulationScenario(
      title: 'البحث عن سكن (Wohnungssuche)',
      category: 'سكن وحياة',
      icon: Icons.home_work_rounded,
      phrases: [
        'Ist die Wohnung noch frei?',
        'Wie hoch ist die Warmmiete inklusive Nebenkosten?',
        'Gibt es eine Kaution für die Wohnung?',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('محاكاة الحياة اليومية', style: AppStyles.title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _scenarios.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final s = _scenarios[index];
            return AppCard(
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Icon(s.icon, color: AppColors.primary),
                ),
                title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text(s.category, style: AppStyles.subtitle),
                children: [
                  const Divider(),
                  ...s.phrases.map((phrase) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.secondary),
                            const SizedBox(width: 8),
                            Expanded(child: AppDirectionalText.target(phrase, style: AppStyles.body.copyWith(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
