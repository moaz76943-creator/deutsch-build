import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import 'grammar_guide_screen.dart';

class VerbConjugationScreen extends StatefulWidget {
  const VerbConjugationScreen({super.key});

  @override
  State<VerbConjugationScreen> createState() => _VerbConjugationScreenState();
}

class _VerbConjugationScreenState extends State<VerbConjugationScreen> {
  String _selectedTense = 'المضارع (Präsens)';

  final Map<String, dynamic> _verbData = const {
    'verb': 'haben (يملك)',
    'type': 'غير منتظم (Unregelmäßig)',
    'forms': {
      'ich': 'habe',
      'du': 'hast',
      'er / sie / es': 'hat',
      'wir': 'haben',
      'ihr': 'habt',
      'sie / Sie': 'haben',
    },
  };

  @override
  Widget build(BuildContext context) {
    final forms = _verbData['forms'] as Map<String, String>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تصريف الأفعال الألمانية'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.school_rounded),
            tooltip: 'دليل القواعد',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GrammarGuideScreen()),
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppBaseGlassCard(
                  gradient: AppGradients.purpleCard,
                  child: Row(
                    children: <Widget>[
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white24,
                        child:
                            Icon(Icons.flash_on_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _verbData['verb'] as String,
                              style: AppTypography.display
                                  .copyWith(color: Colors.white, fontSize: 20),
                            ),
                            Text(
                              _verbData['type'] as String,
                              style: AppTypography.body.copyWith(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children:
                      ['المضارع (Präsens)', 'الماضي (Perfekt)'].map((tense) {
                    final isSel = _selectedTense == tense;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Center(
                              child: Text(tense,
                                  style: const TextStyle(fontSize: 12))),
                          selected: isSel,
                          onSelected: (_) =>
                              setState(() => _selectedTense = tense),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.separated(
                    itemCount: forms.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final pronoun = forms.keys.elementAt(idx);
                      final conjugated = forms[pronoun]!;
                      return AppBaseGlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
<<<<<<< HEAD
                            Text(
                              pronoun,
                              style: AppTypography.title.copyWith(
                                  color: Colors.white70, fontSize: 16),
                            ),
=======
                            Expanded(
                                      child: Text(
                                        pronoun,
                                        style: AppTypography.title.copyWith(color: Colors.white70, fontSize: 16),
                                      ),
                                    ),
>>>>>>> origin/staging/v2-full-platform-9617688105299726044
                            Text(
                              conjugated,
                              style: AppTypography.display.copyWith(
                                  color: const Color(0xFF38BDF8), fontSize: 18),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
