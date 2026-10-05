import 'package:deutsch_bilarabi/features/phase3_integration/life_feature_text.dart';

import '../../../design_system/design_system.dart';
import 'assembly_models.dart';
import 'assembly_service_agent.dart';
import 'defects_reklamation_agent.dart';

final class AssemblyDefectsHubController extends ChangeNotifier {
  AssemblyDefectsHubController({
    AssemblyServiceAgent assemblyAgent = const AssemblyServiceAgent(),
    DefectsReklamationAgent defectsAgent = const DefectsReklamationAgent(),
  }) : _scenarios = <AssemblyScenario>[
          ...assemblyAgent.scenarios,
          ...defectsAgent.scenarios,
        ];

  final List<AssemblyScenario> _scenarios;
  AssemblyIssue _issue = AssemblyIssue.instructions;
  String _query = '';

  AssemblyIssue get issue => _issue;
  String get query => _query;

  List<AssemblyScenario> get visibleScenarios =>
      List<AssemblyScenario>.unmodifiable(
        _scenarios.where(
          (scenario) => scenario.issue == _issue && scenario.matches(_query),
        ),
      );

  void setIssue(AssemblyIssue value) {
    if (_issue == value) return;
    _issue = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }
}

final class AssemblyDefectsScreen extends StatefulWidget {
  const AssemblyDefectsScreen({super.key});

  @override
  State<AssemblyDefectsScreen> createState() => _AssemblyDefectsScreenState();
}

final class _AssemblyDefectsScreenState extends State<AssemblyDefectsScreen> {
  late final AssemblyDefectsHubController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AssemblyDefectsHubController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            dark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('التركيب والقطع الناقصة · Aufbau & Reklamation'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    onChanged: _controller.setQuery,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Suche · بحث',
                      hintText: 'Aufbauanleitung, Schrauben, verkratzt ...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppGlassCard(
                    backgroundColor: surface,
                    borderColor: AppColors.primary.withAlpha(88),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        for (final issue in AssemblyIssue.values)
                          FilterChip(
                            selected: _controller.issue == issue,
                            onSelected: (_) => _controller.setIssue(issue),
                            label: Text(_issueLabel(issue)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final scenario in _controller.visibleScenarios) ...<Widget>[
                    AppGlassCard(
                      backgroundColor: surface,
                      borderColor: AppColors.secondary.withAlpha(88),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          AppDirectionalText(
                            scenario.titleDe,
                            languageCode: 'de',
                            style: AppTypography.title,
                          ),
                          AppDirectionalText(
                            scenario.titleAr,
                            languageCode: 'ar',
                            style: AppTypography.label,
                          ),
                          const SizedBox(height: 8),
                          AppDirectionalText(
                            scenario.german,
                            languageCode: 'de',
                            style: AppTypography.body,
                          ),
                          const SizedBox(height: 6),
                          AppDirectionalText(
                            scenario.arabic,
                            languageCode: 'ar',
                            style: AppTypography.body,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _issueLabel(AssemblyIssue issue) => switch (issue) {
        AssemblyIssue.instructions => 'Anleitung',
        AssemblyIssue.tools => 'Werkzeuge',
        AssemblyIssue.montageService => 'Montageservice',
        AssemblyIssue.missingPart => 'Fehlendes Teil',
        AssemblyIssue.wrongScrew => 'Schrauben',
        AssemblyIssue.transportDamage => 'Transportschaden',
      };
}
