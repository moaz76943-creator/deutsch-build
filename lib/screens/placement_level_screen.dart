import 'package:flutter/material.dart';

import 'package:deutsch_bilarabi/design_system/design_system.dart';

class PlacementLevelScreen extends StatefulWidget {
  const PlacementLevelScreen({required this.onComplete, super.key});
  final VoidCallback onComplete;

  @override
  State<PlacementLevelScreen> createState() => _PlacementLevelScreenState();
}

class _PlacementLevelScreenState extends State<PlacementLevelScreen> {
  String _selectedLevel = 'A1';

  final levels = const [
    {'id': 'A1', 'name': 'مبتدئ تماماً (A1)', 'desc': 'الحروف، الأرقام، أدوات التعريف والجمل اليومية الأولى.'},
    {'id': 'A2', 'name': 'أساسيات التواصل (A2)', 'desc': 'الماضي البسيط، المحادثات في السوق والعمل والمطاعم.'},
    {'id': 'B1', 'name': 'المستوى المتوسط (B1)', 'desc': 'تراكيب الجمل المعقدة، التعبير عن الرأي والقصص.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 16),
                Text(
                  'ما هو مستواك الحالي؟',
                  style: AppTypography.display.copyWith(color: Colors.white, fontSize: 26),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'سنقوم بتخصيص مسار التعلم ليناسب معرفتك الحالية',
                  style: AppTypography.body.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: ListView.separated(
                    itemCount: levels.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = levels[index];
                      final isSelected = _selectedLevel == item['id'];
                      return AppBaseGlassCard(
                        onTap: () => setState(() => _selectedLevel = item['id']!),
                        gradient: isSelected ? AppGradients.purpleCard : null,
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                item['id']!,
                                style: AppTypography.title.copyWith(color: Colors.white, fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item['name']!,
                                    style: AppTypography.title.copyWith(color: Colors.white, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['desc']!,
                                    style: AppTypography.body.copyWith(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: widget.onComplete,
                  child: const Text('بدء المسار التعليمي'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
