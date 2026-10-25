import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';

class SmartErrorReviewScreen extends StatefulWidget {
  const SmartErrorReviewScreen({super.key});

  @override
  State<SmartErrorReviewScreen> createState() => _SmartErrorReviewScreenState();
}

class _SmartErrorReviewScreenState extends State<SmartErrorReviewScreen> {
  final List<Map<String, String>> _errorItems = [
    {
      "word": "der Laptop",
      "translation": "الحاسوب المحمول",
      "rule": "اسم مذكر يأخذ الأداة (der)",
      "language": "الألمانية"
    },
    {
      "word": "por lo tanto",
      "translation": "لذلك / بناءً عليه",
      "rule": "تعبير ظرفي متقدم في الإسبانية",
      "language": "الإسبانية"
    },
    {
      "word": "geliyor",
      "translation": "هو قادم",
      "rule": "تصريف الفعل الحاضر المستمر بالتركية",
      "language": "التركية"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مراجعة الأخطاء الذكية (SRS)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.darkScaffold),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Text('🧠', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'ذاكرة التصحيح التكيفي',
                              style: AppTypography.display
                                  .copyWith(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'هنا يتم جمع الكلمات والقواعد التي واجهت صعوبة فيها لتثبيتها نهائياً.',
                              style: AppTypography.body.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'قائمة المراجعة الحالية (${_errorItems.length} عناصر)',
                  style: AppTypography.display
                      .copyWith(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: _errorItems.length,
                    itemBuilder: (context, index) {
                      final item = _errorItems[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: AppBaseGlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    item['word']!,
                                    style: AppTypography.display.copyWith(
                                        color: const Color(0xFF38BDF8),
                                        fontSize: 20),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item['language']!,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'المعنى: ${item['translation']}',
                                style: AppTypography.body.copyWith(
                                    color: Colors.white, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ' القاعدة: ${item['rule']}',
                                style: AppTypography.body.copyWith(
                                    color: const Color(0xFF34D399),
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
