import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

String _emergencyPhraseHeroTag(Map<String, String> phrase) =>
    'emergency_phrase_${phrase['title'] ?? ''}';

/// Offline phrases remain bundled; opening details never triggers a download.
class EmergencyPhrasebookScreen extends StatelessWidget {
  const EmergencyPhrasebookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> phrases = [
      {
        "title": "أحتاج إلى طبيب فوراً",
        "trans": "Ich brauche sofort einen Arzt",
        "icon": "🏥"
      },
      {
        "title": "أين أقرب صيدلية؟",
        "trans": "Wo ist die nächste Apotheke?",
        "icon": "💊"
      },
      {
        "title": "لقد ضاع جواز سفرى",
        "trans": "Mein Reisepass ist verloren gegangen",
        "icon": "✈️"
      },
      {"title": "النجدة / الشرطة", "trans": "Hilfe / Polizei", "icon": "🚨"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('عبارات السفر والطارئة (بدون إنترنت)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            // Performance: bound pre-build area beyond viewport (default ~250).
            // Moderate value balances smoothness vs memory even on short phrase lists.
            cacheExtent: 300,
            // Pure StatelessWidget cards; no persistent state to keep alive when off-screen.
            // Disabling reduces memory pressure if the list grows or during rapid navigation.
            addAutomaticKeepAlives: false,
            itemCount: phrases.length,
            itemBuilder: (context, index) {
              final item = phrases[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RepaintBoundary(
                  // Isolates repaint of each emergency phrase card. Reduces overpaint
                  // during scroll or when sibling items update on complex glass cards
                  // with Hero icons and nested text.
                  // Expected: fewer dropped frames on phrasebook scroll,
                  // especially on mid-range devices.
                  child: Semantics(
                    button: true,
                    child: AppBaseGlassCard(
                      padding: const EdgeInsets.all(16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => EmergencyPhrasebookDetailScreen(
                              item: item,
                            ),
                          ),
                        );
                      },
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: <Widget>[
                            Hero(
                              tag: _emergencyPhraseHeroTag(item),
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  item['icon']!,
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item['title']!,
                                    softWrap: true,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['trans']!,
                                    textDirection: TextDirection.ltr,
                                    softWrap: true,
                                    style: const TextStyle(
                                      color: Color(0xFF34D399),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

/// A bounded, scrollable detail surface for accessibility text scaling.
class EmergencyPhrasebookDetailScreen extends StatelessWidget {
  const EmergencyPhrasebookDetailScreen({
    super.key,
    required this.item,
  });

  final Map<String, String> item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['title'] ?? ''),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: AppBaseGlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Hero(
                          tag: _emergencyPhraseHeroTag(item),
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              item['icon'] ?? '',
                              style: const TextStyle(fontSize: 76),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          item['title'] ?? '',
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item['trans'] ?? '',
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: const TextStyle(
                            color: Color(0xFF34D399),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
