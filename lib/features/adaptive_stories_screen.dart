import 'package:flutter/material.dart';
import '../ui/app_design_system.dart';
import '../ui/app_directional_text.dart';

class AdaptiveStoriesScreen extends StatelessWidget {
  const AdaptiveStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('قصص تتكيف مع مستواك', style: AppStyles.title),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('قصة: يوم في برلين (Ein Tag in Berlin)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Text('مستوى A2', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppDirectionalText.target(
                    'Sami kommt am Morgen am Berliner Hauptbahnhof an. Das Wetter ist schön und die Sonne scheint. Er nimmt die U-Bahnlinie 2 und fährt direkt zum Alexanderplatz. Dort trifft er seinen Freund Lukas in einem kleinen Café.',
                    style: AppStyles.body.copyWith(height: 1.6, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text('سؤال الفهم السريع:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Wie fährt Sami zum Alexanderplatz?'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(label: const Text('Mit dem Bus'), onPressed: () {}),
                      ActionChip(label: const Text('Mit der U-Bahn 2'), onPressed: () {}),
                      ActionChip(label: const Text('Zu Fuß'), onPressed: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
