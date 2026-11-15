import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class ThemeSwitcherScreen extends StatelessWidget {
  const ThemeSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> themes = [
      {
        "name": "\u0627\u0644\u0646\u0645\u0637 \u0627\u0644\u0641\u0636\u0627\u0626\u064a \u0627\u0644\u0644\u064a\u0644\u064a (Dark Space)",
        "color": const Color(0xFF0F172A),
        "active": true
      },
      {
        "name": "\u0627\u0644\u0646\u0645\u0637 \u0627\u0644\u0632\u0645\u0631\u062f\u064a \u0627\u0644\u0623\u062e\u0636\u0631 (Emerald Glow)",
        "color": const Color(0xFF064E3B),
        "active": false
      },
      {
        "name": "\u0627\u0644\u0646\u0645\u0637 \u0627\u0644\u0645\u0644\u0643\u064a \u0627\u0644\u0646\u064a\u0644\u064a (Royal Indigo)",
        "color": const Color(0xFF312E81),
        "active": false
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('\u062a\u062e\u0635\u064a\u0635 \u0627\u0644\u062b\u064a\u0645\u0627\u062a \u0648\u0627\u0644\u0623\u0644\u0648\u0627\u0646'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              // Performance: bound pre-build area beyond viewport (default ~250 px).
              // Moderate value balances smoothness vs memory on glass cards.
              cacheExtent: 300,
              addAutomaticKeepAlives: false,
              itemCount: themes.length,
              itemBuilder: (context, index) {
                final theme = themes[index];
                final bool active = theme['active'] as bool;

                return RepaintBoundary(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: AppBaseGlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme['color'] as Color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              theme['name'] as String,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (active)
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF34D399)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
