import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

<<<<<<< HEAD
String _emergencyPhraseHeroTag(Map<String, String> phrase) =>
    'emergency_phrase_${phrase['title'] ?? ''}';

/// Offline phrases remain bundled; opening details never triggers a download.
=======
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: phrases.length,
              itemBuilder: (context, index) {
                final item = phrases[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: AppBaseGlassCard(
                    padding: const EdgeInsets.all(16),
<<<<<<< HEAD
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
=======
                    child: Row(
                      children: <Widget>[
                        Text(item['icon']!, style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(item['title']!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(item['trans']!, style: const TextStyle(color: Color(0xFF34D399), fontSize: 14)),
                            ],
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
                          ),
                        ],
                      ),
                    ),
                  ),
<<<<<<< HEAD
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
=======
                );
              },
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
            ),
          ),
        ),
      ),
    )
  }
}

class EmergencyPhrasebookDetailScreen extends StatelessWidget {
  final Map<String, String> item;

  const EmergencyPhrasebookDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['title']!),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Center(
            child: AppBaseGlassCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: 'emergency_phrase_${item['title']}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(item['icon']!,
                          style: const TextStyle(fontSize: 96)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(item['title']!,
                      style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text(item['trans']!,
                      style: const TextStyle(
                          color: Color(0xFF34D399), fontSize: 18),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
