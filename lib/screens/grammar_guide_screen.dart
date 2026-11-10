import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class GrammarGuideScreen extends StatelessWidget {
  const GrammarGuideScreen({super.key});

  final List<Map<String, String>> _rules = const [
    {
      'title': 'ترتيب الجملة الرئيسية (Hauptsatz)',
      'desc':
          'الفعل يأتي دائماً في الموقع الثاني (Position 2)، بغض النظر عما يبدأ به السطر.',
      'example': 'Heute lerne ich Deutsch.',
    },
    {
      'title': 'الأفعال المنفصلة (Trennbare Verben)',
      'desc':
          'ينفصل المقطع الأول ويذهب إلى نهاية الجملة تماماً في زمن المضارع.',
      'example': 'Ich stehe um 7 Uhr auf.',
    },
    {
      'title': 'أفعال الكيفية / المودال (Modalverben)',
      'desc':
          'فعل المودال يأتي في المركز الثاني مصرفاً، والفعل الأساسي يذهب لمصدره في النهاية.',
      'example': 'Ich möchte einen Kaffee trinken.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل القواعد النحوية'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            // Performance: bound pre-build area beyond viewport (default ~250).
            // Moderate value balances smoothness vs memory even on short rule lists.
            cacheExtent: 300,
            // Pure StatelessWidget cards; no persistent state to keep alive when off-screen.
            // Disabling reduces memory pressure if the list grows or during rapid navigation.
            addAutomaticKeepAlives: false,
            itemCount: _rules.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, idx) {
              final r = _rules[idx];
              return RepaintBoundary(
                // Isolates repaint of each grammar rule card. Reduces overpaint
                // during scroll or when sibling items update on complex glass cards
                // with gradients and nested containers.
                // Expected: fewer dropped frames on grammar guide scroll,
                // especially on mid-range devices.
                child: AppBaseGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        r['title']!,
                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        r['desc']!,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.lightbulb_outline_rounded,
                                color: Color(0xFFF39C6B), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                r['example']!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
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
    );
  }
}
