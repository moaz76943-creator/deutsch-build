import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class ThemeSwitcherScreen extends StatelessWidget {
  const ThemeSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> themes = [
      {"name": "النمط الفضائي الليلي (Dark Space)", "color": const Color(0xFF0F172A), "active": true},
      {"name": "النمط الزمردي الأخضر (Emerald Glow)", "color": const Color(0xFF064E3B), "active": false},
      {"name": "النمط الملكي النيلي (Royal Indigo)", "color": const Color(0xFF312E81), "active": false},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('تخصيص الثيمات والألوان'),
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
              itemCount: themes.length,
              itemBuilder: (context, index) {
                final theme = themes[index];
                final bool active = theme['active'] as bool;

                return Container(
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
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (active)
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399)),
                      ],
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
