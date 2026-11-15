import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class ContextualNewsScreen extends StatelessWidget {
  const ContextualNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> articles = [
      {
        "title": "Der morgendliche Kaffee in Berlin",
        "translation": "قهوة الصباح في برلين",
        "snippet": "Jeden Tag trinken Millionen Deutsche ihren Filterkaffee...",
        "level": "A2"
      },
      {
        "title": "Un café con vistas al mar",
        "translation": "قهوة مع إطلالة على البحر",
        "snippet": "La costa española ofrece una variedad increíble de...",
        "level": "B1"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('مقالات الغمر اللغوي اليومي'),
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
              // Moderate value balances smoothness vs memory on complex glass cards.
              cacheExtent: 300,
              addAutomaticKeepAlives: false,
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return RepaintBoundary(
                  // Isolates repaint of each news card. Reduces overpaint
                  // when sibling items update or during scroll on nested glass cards
                  // with badges, colored text, and multi-line snippets.
                  // Expected: fewer dropped frames on news list scroll.
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: AppBaseGlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  article['title']!,
                                  style: AppTypography.display.copyWith(color: const Color(0xFF38BDF8), fontSize: 16),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  article['level']!,
                                  style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            article['translation']!,
                            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            article['snippet']!,
                            style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                          ),
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
