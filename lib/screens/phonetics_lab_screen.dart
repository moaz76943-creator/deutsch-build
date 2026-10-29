import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class PhoneticsLabScreen extends StatelessWidget {
  const PhoneticsLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> sounds = [
      {"symbol": "ä / ö / ü", "desc": "حروف التملق (Umlaut) وكيفية تدوير الشفاه بالألمانية", "lang": "الألمانية"},
      {"symbol": "ñ", "desc": "حرف النون المضخم في اللغة الإسبانية", "lang": "الإسبانية"},
      {"symbol": "ğ", "desc": "الحرف الصامت أو الناعم في اللغة التركية", "lang": "التركية"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('معمل تدريب الصوتيات ومخارج الحروف'),
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
              itemCount: sounds.length,
              itemBuilder: (context, index) {
                final item = sounds[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: AppBaseGlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF34D399).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item['symbol']!,
                            style: const TextStyle(color: Color(0xFF34D399), fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item['lang']!,
                                style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['desc']!,
                                style: AppTypography.body.copyWith(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
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
