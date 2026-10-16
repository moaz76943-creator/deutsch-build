import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class GrammarCheatSheetScreen extends StatelessWidget {
  const GrammarCheatSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> rules = [
      {"title": "أدوات التعريف الألمانية (Der / Die / Das)", "desc": "Der (مذكر), Die (مؤنث / جمع), Das (محايد)", "lang": "الألمانية"},
      {"title": "تصريف الأفعال في الحاضر (Präsens)", "desc": "إضافة نهايات محددة حسب الضمير (ich -e, du -st, er/sie/es -t)", "lang": "الألمانية"},
      {"title": "أفعال الكينونة والملكيه الأساسية", "desc": "sein (يكون) و haben (يملك) وتصريفاتهما في الجملة", "lang": "الألمانية"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل القواعد السريع (Cheat Sheets)'),
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
              itemCount: rules.length,
              itemBuilder: (context, index) {
                final rule = rules[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: AppBaseGlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          rule['title']!,
                          style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          rule['desc']!,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
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
